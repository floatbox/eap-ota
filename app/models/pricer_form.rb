class PricerForm < ActiveRecord::BaseWithoutTable

  column :from, :string
  column :to, :string
  column :date1, :string,  (Date.today + 10.days).strftime('%d%m%y')
  column :date2, :string,  (Date.today + 15.days).strftime('%d%m%y')
  column :rt, :boolean
  column :adults, :integer, 1
  column :children, :integer, 0
  column :search_type, :string, 'travel'
  column :nonstop, :boolean
  column :day_interval, :integer, 1
  column :debug, :boolean, false
  
  validates_presence_of :from, :to, :date1
  validates_presence_of :date2, :if => :rt


  def to_key
    []
  end

  def travel_xml
    Amadeus.fare_master_pricer_travel_board_search(self)
  end

  def calendar_xml
    Amadeus.fare_master_pricer_calendar(self)
  end

  def search
    case search_type
    when 'travel'
      parse(travel_xml)
    when 'calendar'
      parse(calendar_xml)
    end
  end

  def parse(xml=travel_xml)
    flight_indexes = xml.xpath('//r:flightIndex').map do |flight_index|
      flight_index.xpath('r:groupOfFlights').map do |group|
        Segment.new(
          :flights => group.xpath("r:flightDetails/r:flightInformation").map { |fi| parse_flight(fi) }
        )
      end
    end

    recommendations = xml.xpath("//r:recommendation").map do |rec|
      prices = rec.xpath("r:recPriceInfo/r:monetaryDetail/r:amount").collect {|x| x.to_f }
      price_total = prices.sum

      variants = rec.xpath("r:segmentFlightRef").map {|sf|
        segments = sf.xpath("r:referencingDetail").each_with_index.collect { |rd, i|
          # TODO проверить что:
          # rd["refQualifier"] == "S"
          flight_indexes[i][ rd.xpath("r:refNumber").to_i - 1 ]
        }
        Variant.new( :segments => segments )
      }
      
      additional_info =
        rec.xpath('.//r:fare').map {|f|
          f.xpath('.//r:description|.//r:textSubjectQualifier').every.to_s.join("\n")
        }.join("\n\n") +
        "\n\nfareBasis: " +
        rec.xpath('.//r:fareBasis').to_s

      Recommendation.new(
        :prices => prices,
        :price_total => price_total,
        :variants => variants,
        :additional_info => additional_info
      )
    end

  end

  # fi: flightInformation node
  def parse_flight(fi)
    Flight.new(
      :operating_carrier_iata => fi.xpath("r:companyId/r:operatingCarrier").to_s,
      :marketing_carrier_iata => fi.xpath("r:companyId/r:marketingCarrier").to_s,
      :departure_iata =>         fi.xpath("r:location[1]/r:locationId").to_s,
      :departure_term =>         fi.xpath("r:location[1]/r:terminal").to_s,
      :arrival_iata =>           fi.xpath("r:location[2]/r:locationId").to_s,
      :arrival_term =>           fi.xpath("r:location[2]/r:terminal").to_s,
      :flight_number =>          fi.xpath("r:flightNumber").to_s,
      :arrival_date =>           fi.xpath("r:productDateTime/r:dateOfArrival").to_s,
      :arrival_time =>           fi.xpath("r:productDateTime/r:timeOfArrival").to_s,
      :departure_date =>         fi.xpath("r:productDateTime/r:dateOfDeparture").to_s,
      :departure_time =>         fi.xpath("r:productDateTime/r:timeOfDeparture").to_s,
      :equipment_type_iata =>    fi.xpath("r:productDetail/r:equipmentType").to_s
    )
  end
  
  def search_offers
    recommendations = search
    offers = []
    recommendations.each do |rec|
      rec.variants.each do |variant|
        #if date2
        #  duration = (date2 - date1).to_i + 1
        #else
          duration = 1
        #end

        offers << Offer.new(
          :segments => variant.segments,
          :persons => children + adults,
          :flight_price => rec.price_total,
          # :company => company,
          :duration => duration
          # :hotel => hotel
        )
      end
    end
    offers
  end
end

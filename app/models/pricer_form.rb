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
  
  validates_presence_of :from_iata, :to_iata, :date1
  validates_presence_of :date2, :if => :rt
  
  attr_reader :to_iata, :from_iata

  cattr_reader :parse_time
  def self.reset_parse_time
    @@parse_time = 0
  end

  def to= name
    @to_iata =  Completer.new_or_cached.iata_from_name(name) rescue nil
    super
  end
  
  def from= name
    @from_iata = Completer.new_or_cached.iata_from_name(name) rescue nil
    super
  end
  
  
  def to_key
    []
  end

  def human
    return "запрос не полон" unless valid?
    r = []
    if from_iata && (from_location = City[from_iata] || Airport[from_iata])
      r << from_location.case_from
    end
    if to_iata && (to_location = City[to_iata] || Airport[to_iata])
      r << to_location.case_to
    end

    r << 'и обратно' if rt

    if adults > 1
      r << ['вдвоем', 'втроем', 'вчетвером', 'впятером', 'вшестером', 'всемером', '8 взрослых'][adults-2]
    end
    if children > 0
      r << ['с ребенком', 'с двумя детьми', 'с тремя детьми', '4 детских', '5 детских', '6 детских', '7 детских'][children-1]
    end

    if rt
      r << human_dates(Date.strptime(date1, '%d%m%y'), Date.strptime(date2, '%d%m%y'))
    else
      r << human_dates(Date.strptime(date1, '%d%m%y'))
    end

    r.join(' ')
  end

  def human_dates(d1, d2=nil)
    if d2.blank?
      if d1.year == Date.today.year
        return I18n.l(d1, :format => '%e %B')
      else
        return I18n.l(d1, :format => '%e %B %Y')
      end

    else
      if d1.year == d2.year
        if d1.month == d2.month
          f1, f2 = '%e', '%e %B'
        else
          f1, f2 = '%e %B', '%e %B'
        end

        if d1.year != Date.today.year
          f2 += ' %Y'
        end
      else
        f1, f2 = '%e %B %Y', '%e %B %Y'
      end

      return "с %s по %s" % [
        I18n.l(d1, :format => f1),
        I18n.l(d2, :format => f2)
      ]
    end
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
    end #.select(&:sellable?)
  end

  def parse(xml=travel_xml)
    recommendations = []
    # TODO сделать инкрементирующийся счетчик
    @@parse_time = Benchmark.ms do
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
    recommendations
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

end

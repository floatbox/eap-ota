# encoding: utf-8

module RamblerApi
  CABINS_MAPPING = {'E' => 'Y', 'A' => 'Y', 'P' => 'C', 'B' => 'C', 'F' => 'F'}
  include KeyValueInit

  def self.redirecting_uri params
    pricer_form_hash = {
        :from => params[:request][:src],
        :to => params[:request][:dst],
        :date1 => params[:request][:dir],
        :date2 => params[:request][:ret],
        :adults => params[:request][:adt].to_i,
        :children => params[:request][:cnn].to_i,
        :infants => params[:request][:inf].to_i,
        :cabin => CABINS_MAPPING[params[:request][:cls]],
        :partner => 'rambler'}
    search = PricerForm.simple(pricer_form_hash)

    direct_flights = params[:response][:dir].collect do |flight|
      Flight.new(
        :operating_carrier_iata => flight[:oa],
        :marketing_carrier_iata => flight[:ma],
        :flight_number => flight[:n],
        :departure_iata => flight[:dep][:p],
        :arrival_iata => flight[:arr][:p],
        :departure_date => flight[:dep][:dt] )
    end
    direct_segments = Segment.new(:flights => direct_flights)

    if (params[:response][:ret] || params[:response][:ret] != [])
      return_flights = params[:response][:ret].collect do |flight|
        Flight.new(
          :operating_carrier_iata => flight[:oa],
          :marketing_carrier_iata => flight[:ma],
          :flight_number => flight[:n],
          :departure_iata => flight[:dep][:p],
          :arrival_iata => flight[:arr][:p],
          :departure_date => flight[:dep][:dt])
        end
      return_segments = Segment.new(:flights => return_flights)
    end
    return_segments ||= nil
    segments = [direct_segments, return_segments]
    variants = Variant.new(:segments => segments)

    booking_classes, cabins = [],[]
    booking_classes, cabins = (params[:response][:dir] + (params[:response][:ret] || [])).each do |segment|
      booking_classes << segment[:bcl]
      cabins << CABINS_MAPPING[segment[:cls]]
      break booking_classes, cabins
    end

    recommendation = Recommendation.new(
      :source => 'amadeus',
      :validating_carrier_iata => params[:response][:va],
      :booking_classes => booking_classes,
      :cabins => cabins,
      :variants => [variants])
    recommendation = recommendation.serialize
    
    if search.valid?
      search.save_to_cache
      uri = {:action => 'preliminary_booking', :query_key => search.query_key, :recommendation => recommendation, :controller => 'booking'}
    elsif search.segments.first.errors.messages.first
      raise ArgumentError, "#{ search.segments.first.errors.messages.first[1][0] }"
    else
      raise ArgumentError, "#{ 'Unknown error' }"
    end
  end

  def self.uri_for_rambler hash
    string = hash.to_query
    uri = "http://eviterra.com/api/manual_booking.xml?#{string}"
  end

  def self.generate_hash search, recommendation
    request = {}
    response = {}

    request[:src] = search.from
    request[:dst] = search.to
    request[:dir] = search.date1
    request[:cls] = search.cabin
    request[:adt] = search.adults

    response[:va] = recommendation.validating_carrier_iata
    response[:dir] = []
    response[:ret] = []

    response[:dir] = recommendation.segments.first.flights.collect do |flight|
      {:oa => flight.operating_carrier_iata,
       :n  => flight.flight_number,
       :ma => flight.marketing_carrier_iata,
       :bcl =>recommendation.booking_class_for_flight(flight),
       :cls =>recommendation.cabin_for_flight(flight),
       :dep => {
          :p => flight.departure_iata,
          :dt => flight.departure_date
        },
       :arr => {
          :p => flight.arrival_iata
        }
      }
    end
    if recommendation.segments.second
      response[:ret] = recommendation.segments.second.flights.collect do |flight|
        {:oa => flight.operating_carrier_iata,
         :n  => flight.flight_number,
         :bcl =>recommendation.booking_class_for_flight(flight),
         :cls =>recommendation.cabin_for_flight(flight),
         :ma => flight.marketing_carrier_iata,
         :dep => {
            :p => flight.departure_iata,
            :dt => flight.departure_date
          },
         :arr => {
            :p => flight.arrival_iata
          }
        }
      end
    end



    rambler_hash = {:response => response, :request => request}
  end

end

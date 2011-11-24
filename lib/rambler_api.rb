# encoding: utf-8

module RamblerApi
  CABINS_MAPPING = {'E' => 'Y', 'A' => '', 'P' => 'C', 'B' => 'C', 'F' => 'F', 'Y' => 'Y', 'C' => 'C'}
  REV_CABINS_MAPPING = {'Y' => 'E', 'C' => 'B', 'F' => 'F', '' => 'A'}
  include KeyValueInit

  def self.redirecting_uri params
    direct_flights = params[:dir].collect do |flight|
      Flight.new(
        :operating_carrier_iata => flight[:oa],
        :marketing_carrier_iata => flight[:ma],
        :flight_number => flight[:n],
        :departure_iata => flight[:dep][:p],
        :arrival_iata => flight[:arr][:p],
        :departure_date => flight[:dep][:dt] )
    end
    direct_segments = Segment.new(:flights => direct_flights)

    if (params[:ret] || params[:ret] != [])
      return_flights = params[:ret].collect do |flight|
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
    booking_classes, cabins = (params[:dir] + (params[:ret] || [])).each do |segment|
      booking_classes << segment[:bcl]
      cabins << CABINS_MAPPING[segment[:cls]]
      break booking_classes, cabins
    end

    recommendation = Recommendation.new(
      :source => 'amadeus',
      :validating_carrier_iata => params[:va],
      :booking_classes => booking_classes,
      :cabins => cabins,
      :variants => [variants])

    date2 = return_flights.first.departure_date if return_flights =! []
    pricer_form_hash = {
        :from => direct_flights.first.departure.city.iata,
        :to => direct_flights.last.arrival.city.iata,
        :date1 => direct_flights.first.departure_date,
        :date2 => date2,
        :adults => 1,
        :cabin => recommendation.cabins.first,
        :partner => 'rambler'}
    search = PricerForm.simple(pricer_form_hash)
    recommendation = recommendation.serialize
    if search.valid?
      search.save_to_cache
      uri = {:action => 'preliminary_booking', :recommendation => recommendation, :controller => 'booking'}
    elsif search.segments.first.errors.messages.first
      raise ArgumentError, "#{ search.segments.first.errors.messages.first[1][0] }"
    else
      raise ArgumentError, "#{ 'Unknown error' }"
    end
  end

  def self.uri_for_rambler hash
    string = hash.to_query
    uri = "http://eviterra.com/api/rambler_booking.xml?#{string}"
  end

  def self.generate_hash recommendation

    hash = {}


    hash[:va] = recommendation.validating_carrier_iata
    hash[:dir] = []
    hash[:ret] = []

    hash[:dir] = recommendation.segments.first.flights.collect do |flight|
      {:oa => flight.operating_carrier_iata,
       :n  => flight.flight_number,
       :ma => flight.marketing_carrier_iata,
       :bcl =>recommendation.booking_class_for_flight(flight),
       :cls =>REV_CABINS_MAPPING[recommendation.cabin_for_flight(flight)],
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
      hash[:ret] = recommendation.segments.second.flights.collect do |flight|
        {:oa => flight.operating_carrier_iata,
         :n  => flight.flight_number,
         :bcl =>recommendation.booking_class_for_flight(flight),
         :cls =>REV_CABINS_MAPPING[recommendation.cabin_for_flight(flight)],
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

    hash
  end

end

# encoding: utf-8

module RamblerApi
  CABINS_MAPPING = {'M' => 'E', 'W' => 'E', 'Y' => 'E', 'C' => 'B', 'F' => 'F'}
  INCOMING_CABINS_MAPPING = {'E' => 'Y', 'B' => 'C', 'F' => 'F'}
  include KeyValueInit

  def self.redirecting_uri params
    direct_flights = []
    params[:dir].sort.map.each do |k , flight|
      direct_flights << Flight.new(
        :operating_carrier_iata => flight[:oa],
        :marketing_carrier_iata => flight[:ma],
        :flight_number => flight[:n],
        :departure_iata => flight[:dep][:p],
        :arrival_iata => flight[:arr][:p],
        :departure_date => flight[:dep][:dt] )
    end
    direct_segments = Segment.new(:flights => direct_flights)

    if params[:ret].present?
      return_flights = []
      params[:ret].sort.map.each do |k, flight|
        return_flights << Flight.new(
          :operating_carrier_iata => flight[:oa],
          :marketing_carrier_iata => flight[:ma],
          :flight_number => flight[:n],
          :departure_iata => flight[:dep][:p],
          :arrival_iata => flight[:arr][:p],
          :departure_date => flight[:dep][:dt])
        end
      return_segments = Segment.new(:flights => return_flights)
    end
    segments = [direct_segments, return_segments]
    segments.compact!
    variants = Variant.new(:segments => segments)

    booking_classes, cabins = [],[]

    params[:dir].sort.map.each do |k, segment|
      booking_classes << segment[:bcl]
      cabins << INCOMING_CABINS_MAPPING[segment[:cls]]
    end
    if params[:ret].present?
      params[:ret].sort.map.each do |k, segment|
        booking_classes << segment[:bcl]
        cabins << INCOMING_CABINS_MAPPING[segment[:cls]]
      end
    end

    recommendation = Recommendation.new(
      :source => 'amadeus',
      :validating_carrier_iata => params[:va],
      :booking_classes => booking_classes,
      :cabins => cabins,
      :variants => [variants])

    date2 = return_flights.first.departure_date if return_flights.present?
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
      uri = "#{Conf.api.url_base}/api/booking/#{search.query_key}#recommendation=#{recommendation}&type=api&partner=#{search.partner}"
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

  def self.recommendation_hash recommendation
    hash, hash[:dir], hash[:ret] = {}, {}, {}
    hash[:va] = recommendation.validating_carrier_iata
    hash[:dir], hash[:ret] = recommendation.segments.map do |segment|
      segment_hash(segment, recommendation)
    end
    hash
  end

  def self.flight_hash flight, recommendation
    cabin = CABINS_MAPPING[recommendation.cabin_for_flight(flight)]
    unless cabin
      raise ArgumentError, "Got unexpected cabin : #{ recommendation.cabin_for_flight(flight)}"
    end
    {:oa => flight.operating_carrier_iata,
       :n  => flight.flight_number,
       :bcl =>recommendation.booking_class_for_flight(flight),
       :cls =>cabin,
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

  def self.segment_hash segment, recommendation
    temp = {}
    segment.flights.each.with_index do |flight, index|
      temp[index.to_s] = flight_hash(flight, recommendation)
    end
    temp
  end
end

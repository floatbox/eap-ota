# encoding: utf-8

module RamblerApi
  CABINS_MAPPING = {'M' => 'E', 'W' => 'E', 'Y' => 'E', 'C' => 'B', 'F' => 'F'}
  INCOMING_CABINS_MAPPING = {'E' => 'Y', 'B' => 'C', 'F' => 'F'}
  include KeyValueInit

  def self.redirecting_uri params
    # array of array of flight_params
    params_for_segments = params.values_at(:dir, :ret).compact.map do |params_with_idx_for_flights|
      params_with_idx_for_flights.sort.map {|idx, flight_params| flight_params}
    end

    segments = params_for_segments.map do |params_for_segment|
      flights = params_for_segment.map do |flight|
        Flight.new(
          :operating_carrier_iata => flight[:oa],
          :marketing_carrier_iata => flight[:ma],
          :flight_number => flight[:n],
          :departure_iata => flight[:dep][:p],
          :arrival_iata => flight[:arr][:p],
          :departure_date => flight[:dep][:dt]
        )
      end
      Segment.new(:flights => flights)
    end

    booking_classes, cabins =
      params_for_segments.flatten.map do |flight_params|
        [ flight_params[:bcl], INCOMING_CABINS_MAPPING[flight_params[:cls]] ]
      end.transpose

    recommendation = Recommendation.new(
      :source => 'amadeus',
      :validating_carrier_iata => params[:va],
      :booking_classes => booking_classes,
      :cabins => cabins,
      :variants => [ Variant.new(:segments => segments) ]
    )

    pricer_form_hash = {
        :from => segments.first.departure.city.iata,
        :to => segments.first.arrival.city.iata,
        :date1 => segments[0].departure_date,
        :date2 => segments[1].try(:departure_date),
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

  def self.recommendation_hash recommendation, variant
    hash = {}
    hash[:va] = recommendation.validating_carrier_iata
    hash[:dir], hash[:ret] = variant.segments.map do |segment|
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

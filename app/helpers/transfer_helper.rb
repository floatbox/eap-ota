# encoding: utf-8
module TransferHelper

  def iway_link order_form
    return unless uri_params = iway_uri_params(order_form)
    "#{uri_params.to_query}"
  end

  def iway_uri_params order_form
    return unless order_form
    return unless order_form.recommendation
    journey = order_form.recommendation.journey
    {
      'departure' => iway_departure(journey.segments.first.flights.first),
      'arrival' => iway_arrival(journey.segments.first.flights.last),
      'person' => iway_people(order_form)
    }
  end

  def iway_departure flight
    {
      'iata' => flight.departure_iata,
      'terminal' => flight.departure_term,
      'flight_number' => flight.full_flight_number,
      'datetime' => flight.departure_datetime_utc
    }
  end

  def iway_arrival flight
    {
      'iata' => flight.arrival_iata,
      'terminal' => flight.arrival_term,
      'flight_number' => flight.full_flight_number,
      'datetime' => flight.arrival_datetime_utc
    }
  end

  def iway_people order_form
    {
      'name_last' => order_form.people.first.last_name,
      'name_first' => order_form.people.first.first_name,
      'email' => order_form.email,
      'phone' => order_form.phone,
      'nationality' => order_form.people.first.nationality.iata
    }
  end

  def iway_date date
    date.strftime('%d.%m.%Y')
  end
end

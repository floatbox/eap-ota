# encoding: utf-8
module HotelsHelper

  def ostrovok_uri uri_params
    "http://hotels.eviterra.com/hotels/?utm_campaign=deeplink&utm_medium=partners&utm_source=eviterracom&partner_slug=eviterracom&#{uri_params.to_query}"
  end

  def ostrovok_link order_form
    return unless uri_params = ostrovok_uri_params(order_form)
    ostrovok_uri uri_params
  end

  def pnr_ostrovok_link flights, passengers
    return unless uri_params = pnr_ostrovok_uri_params(flights, passengers)
    ostrovok_uri uri_params
  end

  def ostrovok_uri_params order_form
    return unless order_form
    return unless order_form.recommendation
    journey = order_form.recommendation.journey
    start_date = journey.segments.first.arrv_date
    end_date =
      if journey.segments.count > 1
        journey.segments.last.dept_date
      else
        start_date + 3.days
      end
    {
      'dates' => ostrovok_date(start_date) + '-' + ostrovok_date(end_date),
      'q' => journey.segments.first.arrival.city.name_en,
      'guests' => order_form.people.count
    }
  end

  def pnr_ostrovok_uri_params flights, passengers
    return unless flights
    journey = destination flights
    return unless journey
    start_date = journey[:arrv_date]
    end_date = journey[:dept_date]
    {
      'dates' => ostrovok_date(start_date) + '-' + ostrovok_date(end_date),
      'q' => journey[:city].name_en,
      'guests' => passengers.count
    }
  end

  def ostrovok_date date
    date.strftime('%d.%m.%Y')
  end

  def ostrovok_city order_form
    order_form.recommendation.journey.segments.first.arrival.city.case_in
  end

  def pnr_ostrovok_city flights
    journey = destination flights
    return unless journey
    journey[:city].case_in
  end

  def destination flights
    return unless flights.first
    point = {}
    long_stop_point = {}
    long_stop_time = 0
    start_point_iata = flights.first.departure_iata
    flights.each do |fl|
      if point[:iata]
        point[:dt] = fl.departure_datetime_utc
        point[:dept_date] = fl.dept_date
        if point[:dt] - point[:at] > long_stop_time
          long_stop_point = point.clone
          long_stop_time = point[:dt] - point[:at]
        end
      end
      point[:city] = fl.arrival.city
      point[:iata] = fl.arrival_iata
      point[:arrv_date] = fl.arrv_date
      point[:at] = fl.arrival_datetime_utc
    end
    if point[:iata] != start_point_iata
      point[:dept_date] = point[:arrv_date] + 3.days
      return point
    end
    return long_stop_point unless long_stop_point.empty?
  end

end

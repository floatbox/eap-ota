# encoding: utf-8
module HotelsHelper

  def ostrovok_uri order_form
    return unless uri_params = ostrovok_uri_params(order_form)
    "http://ostrovok.ru/hotels/?partner_slug=eviterracom&#{uri_params.to_query}"
  end

  def ostrovok_uri_params order_form
    return unless order_form
    return unless order_form.recommendation
    journey = order_form.recommendation.journey
    start_date = journey.segments.first.dept_date
    end_date =
      if journey.segments.count > 1
        journey.segments.last.arrv_date
      else
        insurance_start_date + 3.days
      end
    { 'dates' => ostrovok_date(start_date) + '-' + ostrovok_date(end_date),
      'q' => journey.segments.first.arrival.city.name_en,
      'guests' => order_form.people.count
    }
  end

  def ostrovok_date date
    date.strftime('%d.%m.%Y')
  end
  
  def ostrovok_city order_form
    order_form.recommendation.journey.segments.first.arrival.city.case_in
  end
end

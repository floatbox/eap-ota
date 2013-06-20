# encoding: utf-8
module ExcursionsHelper

  def weatlas_link order_form
    return unless uri_params = weatlas_uri_params(order_form)
    weatlas_uri uri_params
  end

  def tripster_link order_form
    return unless MongoStorage.read('cities',:namespace=>'tripster')
    return unless MongoStorage.read('cities',:namespace=>'tripster').include?(order_form.recommendation.journey.segments.first.arrival.city.iata)
    return unless uri_params = tripster_uri_params(order_form)
    tripster_uri uri_params
  end

  def weatlas_uri uri_params
    "http://weatlas.com/get.php?aid=10002&#{uri_params.to_query}"
  end

  def tripster_uri uri_params
    "http://experience.tripster.ru/partner/v1/iata?partner=eviterra&content=v1&#{uri_params.to_query}"
  end

  def weatlas_uri_params order_form
    return unless order_form
    return unless order_form.recommendation
    {
      'code' =>order_form.recommendation.journey.segments.first.arrival.city.iata
    }
  end

  def tripster_uri_params order_form
    return unless order_form
    return unless order_form.recommendation

    journey = order_form.recommendation.journey
    departure_date = journey.segments.first.arrv_date
    return_date =
      if journey.segments.count > 1
        journey.segments.last.dept_date
      else
        departure_date + 7.days
      end
    {
      'city' => order_form.recommendation.journey.segments.first.arrival.city.iata,
      'departure' => tripster_date(departure_date),
      'return' => tripster_date(return_date)
    }
  end

  def city_case_in order_form
    order_form.recommendation.journey.segments.first.arrival.city.case_in
  end

  def tripster_date date
    date.strftime('%d.%m.%Y')
  end

end

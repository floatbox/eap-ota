# encoding: utf-8
module ExcursionsHelper

  def weatlas_link order_form
    return unless uri_params = weatlas_uri_params(order_form)
    weatlas_uri uri_params
  end

  def weatlas_uri uri_params
    "http://weatlas.com/get.php?aid=10002&#{uri_params.to_query}"
  end

  def weatlas_uri_params order_form
    return unless order_form
    return unless order_form.recommendation
    {
      'code' =>order_form.recommendation.journey.segments.first.arrival.city.iata
    }
  end

  def weatlas_city order_form
    order_form.recommendation.journey.segments.first.arrival.city.case_in
  end

end

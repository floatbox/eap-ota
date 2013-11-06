# encoding: utf-8
class TechnicalStop
  include KeyValueInit
  attr_accessor :location_iata, :arrival_date, :arrival_time, :departure_date, :departure_time

  def airport
    Airport[location_iata]
  end

  def city
    airport.city
  rescue CodeStash::NotFound
    # если нет аэропорта в базе - возвращаем Псевдо-City
    Rails.logger.info "City with iata: #{location_iata} was not found while rendering technical stops!"
    City.new(iata: location_iata, name_en: location_iata)
  end

end

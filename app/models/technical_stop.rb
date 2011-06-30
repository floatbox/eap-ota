# encoding: utf-8
class TechnicalStop
  include KeyValueInit
  attr_accessor :location_iata, :arrival_date, :arrival_time, :departure_date, :departure_time

  def airport
    Airport[location_iata]
  end

end

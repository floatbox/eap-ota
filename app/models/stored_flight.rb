# encoding: utf-8
class StoredFlight < ActiveRecord::Base

  COLUMNS = [
    :departure_iata,
    :arrival_iata,
    :departure_term,
    :arrival_term,
    :marketing_carrier_iata,
    :operating_carrier_iata,
    :flight_number,
    :dept_date,
    :departure_time,
    :arrv_date,
    :arrival_time,
    :equipment_type_iata,
    :technical_stop_count,
    :duration
  ]

  # создает или обновляет stored flight по его главным ключам
  def self.from_flight(flight)
    attrs = flight_attrs(flight, [:marketing_carrier_iata, :flight_number, :departure_iata, :arrival_iata, :dept_date])
    where(attrs).first_or_initialize.update_attributes( flight_attrs(flight) )
  end

  def to_flight
    @flight ||= Flight.new(flight_attrs(self))
  end

  private

  # FIXME перенести во flight, может быть?
  def flight_attrs(flight, columns=COLUMNS)
    Hash[ columns.map { |column| [column, flight.send(column)] } ]
  end


end

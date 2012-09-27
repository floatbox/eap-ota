# encoding: utf-8
class StoredFlight < ActiveRecord::Base

  has_and_belongs_to_many :tickets

  KEY_COLUMNS = [
    :marketing_carrier_iata,
    :flight_number,
    :departure_iata,
    :arrival_iata,
    :dept_date
  ]

  COLUMNS = KEY_COLUMNS + [
    :departure_term,
    :arrival_term,
    :operating_carrier_iata,
    :departure_time,
    :arrv_date,
    :arrival_time,
    :equipment_type_iata,
    :technical_stop_count,
    :duration
  ]

  validates_presence_of KEY_COLUMNS

  # создает или обновляет stored flight по его главным ключам
  def self.from_flight(flight)
    attrs = flight_attrs(flight, KEY_COLUMNS)
    rec = where(attrs).first_or_initialize
    rec.update_attributes! flight_attrs(flight).compact
    rec
  end

  def to_flight
    @flight ||= Flight.new(flight_attrs(self))
  end


  module FlightAttrs
    # FIXME перенести во flight, может быть?
    private
    def flight_attrs(flight, columns=COLUMNS)
      Hash[ columns.map { |column| [column, flight.send(column)] } ]
    end
  end
  extend FlightAttrs
  include FlightAttrs

end

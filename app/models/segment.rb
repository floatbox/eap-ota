class Segment
  delegate :departure, :departure_iata, :dept_date, :dept_time, :departure_datetime_utc,
    :to => 'flights.first', :allow_nil => true
  delegate :arrival, :arrival_iata, :arrv_date, :arrv_time, :arrival_datetime_utc,
    :to => 'flights.last', :allow_nil => true
  delegate :marketing_carrier, :marketing_carrier_name, :to => 'flights.first', :allow_nil => true

  def layover_durations
    (0...flights.size-1).map do |i|
      (flights[i+1].departure_datetime_utc.to_i -
       flights[i].arrival_datetime_utc.to_i) / 60
    end
  end

  attr_accessor :flights
  attr_accessor :id

  def as_json( options={} )
    {
      :departure => departure,
      :dept_date => dept_date,
      :dept_time => dept_time,
      :arrival => arrival,
      :arrv_date => arrv_date,
      :arrv_time => arrv_time,
      :flights => flights,
      :layover_durations => layover_durations,
      #:duration => duration,
      :total_duration => total_duration
    }
  end

  def initialize keys={}
    self.id = object_id
    keys.each do |attr, value|
      send "#{attr}=", value
    end
  end

  def total_duration
    (arrival_datetime_utc.to_i - departure_datetime_utc.to_i) / 60 rescue 0
  end

  def layovers_count
    flights.size - 1
  end
end

# encoding: utf-8
class Segment

  include KeyValueInit

  delegate :departure, :departure_name, :departure_term, :departure_iata, :dept_date, :departure_date, :dept_time, :departure_time, :departure_datetime_utc,
    :to => 'flights.first', :allow_nil => true
  delegate :arrival, :arrival_name, :arrival_term, :arrival_iata, :arrv_date, :arrival_date, :arrv_time, :arrival_time, :arrival_datetime_utc,
    :to => 'flights.last', :allow_nil => true
  delegate :marketing_carrier, :marketing_carrier_name, :marketing_carrier_iata, :to => 'flights.first', :allow_nil => true

  def layover_durations
    flights.each_cons(2).map do |landing, takeoff|
      (takeoff.departure_datetime_utc.to_i - landing.arrival_datetime_utc.to_i) / 60
    end
  end

  def layovers
    flights[0...-1].map(&:arrival)
  end

  attr_accessor :flights, :eft

  def time_to_day_part(time) #в данном случае time - строка
    case time
    when ('0000'...'0500')
      0 #'night'
    when ('0500'...'1200')
      1 #'morning'
    when ('1200'...'1700')
      2 #'day'
    when ('1700'...'2400')
      3 #'evening'
    end
  end
  
  def arrival_day_part
    time_to_day_part(arrival_time)
  end
  
  def departure_day_part
    time_to_day_part(departure_time)
  end

  # FIXME неужто еще надо?
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

  def total_duration
    #(arrival_datetime_utc.to_i - departure_datetime_utc.to_i) / 60 rescue 0
    # estimated flight time!
    eft[0,2].to_i*60 + eft[2,2].to_i
  end

  def layover_count
    flights.size - 1
  end

  def layovers?
    flights.size > 1
  end

  # comparison, uniquiness, etc.
  def signature
    flights
  end

  def hash
    signature.hash
  end

  def eql?(b)
    signature.eql?(b.signature)
  end
end


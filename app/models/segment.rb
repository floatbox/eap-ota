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

  attr_accessor :flights
  attr_writer :total_duration

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

  def rambler_hash
    flights.map do |f|
      {'oa' => f.operating_carrier_iata,
       'ma' => f.marketing_carrier_iata,
       'n' => f.flight_number.to_i,
       'eq' => f.equipment_type_iata,
       'dur' => f.duration,
       'dep' => {
          'p' => f.departure_iata,
          'dt' => DateTime.strptime( f.departure_date + f.departure_time, '%d%m%y%H%M' ).strftime('%Y-%m-%d %H:%M:00'),
          't' => f.departure_term
         },
      'arr' => {
          'p' => f.arrival_iata,
          'dt' => DateTime.strptime( f.arrival_date + f.arrival_time, '%d%m%y%H%M' ).strftime('%Y-%m-%d %H:%M:00'),
          't' => f.arrival_term
         }
      }
    end
  end

  def total_duration
    @total_duratin ||= ((arrival_datetime_utc.to_i - departure_datetime_utc.to_i) / 60 rescue 0)
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
  alias == eql?
end


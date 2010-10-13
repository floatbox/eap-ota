class Flight

  include KeyValueInit

  attr_accessor :operating_carrier_iata, :marketing_carrier_iata, :departure_iata,
   :departure_term, :arrival_iata, :arrival_term, :flight_number, :arrival_date,
   :arrival_time, :departure_date, :departure_time, :equipment_type_iata, :class_of_service, :seat_count, :warning, :cabin, :segment_number

  def departure
    departure_iata && Airport[departure_iata]
  end

  def arrival
    arrival_iata && Airport[arrival_iata]
  end

  def operating_carrier
    operating_carrier_iata && Airline[operating_carrier_iata]
  end

  def marketing_carrier
    marketing_carrier_iata && Airline[marketing_carrier_iata]
  end

  def equipment_type
    equipment_type_iata && Airplane[equipment_type_iata]
  end

  delegate :name, :prefix => true, :allow_nil => true, :to => :departure
  delegate :name, :prefix => true, :allow_nil => true, :to => :arrival
  delegate :name, :prefix => true, :allow_nil => true, :to => :operating_carrier
  delegate :name, :prefix => true, :allow_nil => true, :to => :marketing_carrier
  delegate :name, :prefix => true, :allow_nil => true, :to => :equipment_type

  def arrival_datetime_utc
    local = DateTime.strptime( arrival_date + arrival_time, '%d%m%y%H%M' )
    arrival.tz.local_to_utc(local).to_time
  end

  def departure_datetime_utc
    local = DateTime.strptime( departure_date + departure_time, '%d%m%y%H%M' )
    departure.tz.local_to_utc(local).to_time
  end

  def duration
    (arrival_datetime_utc.to_i - departure_datetime_utc.to_i) / 60 rescue 0
  end

  attr_accessor :classes, :distance, :comfort

  def as_json options={}
    {
      :departure => departure,
      :arrival => arrival,
      :company => operating_carrier,
      :arrv_date => arrv_date,
      :arrv_time => arrv_time,
      :dept_date => dept_date,
      :dept_time => dept_time,
      :airplane => equipment_type,
      :classes => classes,
      :duration => duration,
      :distance => distance,
      :comfort => comfort,
      :flight_number => full_flight_number
    }
  end

  def dept_date
    Date.strptime(departure_date, '%d%m%y')
  end

  def arrv_date
    Date.strptime(arrival_date, '%d%m%y')
  end

  def dept_time
    departure_time.scan(/\d\d/).join(':')
  end

  def arrv_time
    arrival_time.scan(/\d\d/).join(':')
  end

  def full_flight_number
    "#{operating_carrier_iata}#{marketing_carrier_iata}#{flight_number}"
  end

  def distance
    self.class.calculate_distance(departure, arrival) rescue 5000
  end
  
  def flight_code(booking_class = nil, s_number = 0)
    #SS LH3240 B 10SEP FRAMOW 1
    full_flight_number + (class_of_service || booking_class ||'Y') + departure_date + departure_iata + arrival_iata + (seat_count || 1).to_s + (segment_number || s_number || 0).to_s
  end
  
  def self.from_flight_code code
    fl = Flight.new
    fl.operating_carrier_iata,
    fl.marketing_carrier_iata,
    fl.flight_number,
    fl.class_of_service,
    fl.departure_date,
    fl.departure_iata,
    fl.arrival_iata,
    fl.seat_count,
    fl.segment_number = /^(\w\w)(\w\w)(\d+)(\w)(\d{6})(\w{3})(\w{3})(\d)(\d)$/.match(code).captures
    fl
  end
  
  def comfort
    :econom
  end
  
  #private
  def self.calculate_distance from, to
    Graticule::Distance::Vincenty.distance(from, to, :kilometers)
  end

  # comparison, uniquiness, etc.
  def signature
    flight_code
  end

  def hash
    signature.hash
  end

  def eql?(b)
    signature.eql?(b.signature)
  end
end

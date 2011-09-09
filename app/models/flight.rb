# encoding: utf-8
class Flight

  include KeyValueInit

  attr_accessor :operating_carrier_iata, :marketing_carrier_iata, :departure_iata,
   :departure_term, :arrival_iata, :arrival_term, :flight_number, :arrival_date,
   :arrival_time, :departure_date, :departure_time, :equipment_type_iata, :warning, :technical_stop_count,
   :technical_stops, :cabin

  def initialize(*)
    @technical_stops = []
    super
  end

  def departure
    Airport[departure_iata]
  end

  def arrival
    Airport[arrival_iata]
  end

  def operating_carrier
    Carrier[operating_carrier_iata]
  end

  def marketing_carrier
    Carrier[marketing_carrier_iata]
  end

  def equipment_type
    Airplane[equipment_type_iata]
  end

  #используем Air_FlightInfo для получения fligh-а из кода pnr, скопиписченого из терминала
  def self.from_amadeus_code (code)
    if m = code.match(/(\w{2})\s?(\d+)\s(\w)\s(\d{2}\w{3})\s\d\s(\w{3})(\w{3})/)
      date = Date.strptime(m[4], '%d%h')
      date += 1.year if date < Date.today
      flight = Amadeus::Service.air_flight_info(:date => date.strftime('%d%m%y'), :number => m[2], :carrier => m[1], :departure_iata => m[5], :arrival_iata => m[6]).flight
    end
  end

  def self.from_short_code (code, source)
    if m = code.match(/(\w{2})\s?(\d+)\s+(\d{6})/)
      date = Date.strptime(m[3], '%d%m%y')
      if source == 'amadeus'
        flight = Amadeus::Service.air_flight_info(:date => date, :number => m[2], :carrier => m[1]).flight
      else
        flight = Sirena::Service.new.raceinfo(:date => date, :flight => m[2], :carrier => m[1]).flight
      end
    end
  end


  delegate :name, :prefix => true, :allow_nil => true, :to => :departure
  delegate :name, :prefix => true, :allow_nil => true, :to => :arrival
  delegate :name, :prefix => true, :allow_nil => true, :to => :operating_carrier
  delegate :name, :prefix => true, :allow_nil => true, :to => :marketing_carrier
  delegate :name, :prefix => true, :allow_nil => true, :to => :equipment_type

  def arrival_datetime_utc
    @arrival_datetime_utc ||=
      arrival.tz.local_to_utc(DateTime.strptime( arrival_date + arrival_time, '%d%m%y%H%M' )).to_time
  end

  def departure_datetime_utc
    @departure_datetime_utc ||=
      departure.tz.local_to_utc(DateTime.strptime( departure_date + departure_time, '%d%m%y%H%M' )).to_time
  end

  def duration
    @duration ||= (arrival_datetime_utc.to_i - departure_datetime_utc.to_i) / 60 rescue 0
  end

  # иногда известно только количество пересадок
  # массив technical_stops в этом случае пустой
  def technical_stop_count
    @technical_stop_count || technical_stops.size
  end

  attr_accessor :classes, :distance

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
    "#{carrier_pair}#{flight_number}"
  end

  def carrier_pair
    if operating_carrier_iata != marketing_carrier_iata
      "#{operating_carrier_iata}:#{marketing_carrier_iata}"
    else
      marketing_carrier_iata
    end
  end

  def distance
    self.class.calculate_distance(departure, arrival) rescue 5000
  end

  # "4U:LH3240FRAMOW101112"
  def flight_code
    "#{ full_flight_number }#{ departure_iata }#{ arrival_iata }#{ departure_date }"
  end

  def destination
    "#{departure_iata} \- #{arrival_iata}"
  end

  def self.from_flight_code code
    fl = Flight.new
    ( fl.operating_carrier_iata,
      fl.marketing_carrier_iata,
      fl.flight_number,
      fl.departure_iata,
      fl.arrival_iata,
      fl.departure_date ) =
      /^(?: (..) : )? (..) (\d+) (...) (...) (\d{6})$/x.match(code).captures
    fl.operating_carrier_iata ||= fl.marketing_carrier_iata
    fl
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
  alias == eql?

  def inspect
    flight_code
  end

  # для отображения в формате, пригодном для script/amadeus SS
  def cryptic(class_of_service=nil, seat_count=1)
    # EI154/C 12JUL DUBLHR 1
    "SS #{marketing_carrier_iata} #{flight_number} #{class_of_service || '?' } #{cryptic_departure_date} #{departure_iata}#{arrival_iata} #{seat_count}"
  end

  MONTH_ENUM = %W(_ JAN FEB MAR APR MAY JUN JUL AUG SEP OCT NOV DEC)

  # "010212" -> "1FEB"
  def cryptic_departure_date
    "#{ departure_date[0,2].to_i }#{ MONTH_ENUM[departure_date[2,2].to_i] }"
  end

end


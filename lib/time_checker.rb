module TimeChecker
  WORK_START_HOUR = 9
  WORK_END_HOUR = 20

  def self.ok_to_sell departure_datetime_utc, last_tkt_date = nil, time_of_sell = nil
    return false if last_tkt_date && last_tkt_date < Date.today && ['production', 'test'].include?(Rails.env)
    last_tkt_date ||= Date.today + 1.day
    time_of_sell ||= Time.now
    return departure_datetime_utc > time_of_sell + 24.hours  if time_of_sell.hour < WORK_START_HOUR

    return time_of_sell + 4.hours < departure_datetime_utc if (WORK_START_HOUR...WORK_END_HOUR).include? time_of_sell.hour
    return departure_datetime_utc > time_of_sell + 24.hours && last_tkt_date > Date.today
  end

  def self.ok_to_show departure_datetime_utc
    ok_to_sell(departure_datetime_utc, nil, Time.now + 20.minutes)
  end

  def self.ok_to_book departure_datetime_utc, last_tkt_date = nil
    ok_to_sell(departure_datetime_utc, last_tkt_date, Time.now + 10.minutes)
  end

  def self.nearest_ticketing_time time = nil
    time ||= Time.now
    return time if (WORK_START_HOUR...WORK_END_HOUR).include? time.hour
    return Date.today + WORK_START_HOUR.hours if time.hour < WORK_START_HOUR
    return Date.today + 1.day + WORK_START_HOUR.hours if time.hour >= WORK_END_HOUR
  end

end


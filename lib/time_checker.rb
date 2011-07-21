module TimeChecker
  WORK_START_HOUR = 9
  WORK_END_HOUR = 20



  #Чтобы было время выписать билет и поправить косяки
  #   мы продаем билеты не позднее 4-х часов до вылета

  #Чтобы брони в амадеусе не отменялись авиакомпанией
  #  в не рабочее время
  #    мы продаем билеты не позднее 24-х часов до вылета
  #Чтобы маска не протухала
  #  после окончания рабочего дня (до полуночи)
  #    мы не продаем билеты с last_tkt_date - сегодня
  def self.ok_to_sell departure_datetime_utc, last_tkt_date = nil, time_of_sell = nil
    #тк тестовый амадеус живет в прошлом
    last_tkt_date = Date.today + 1.day if !last_tkt_date ||
          (Conf.amadeus.no_ltd_restrictions && last_tkt_date < Date.today)
    time_of_sell ||= Time.now

    return false if last_tkt_date < Date.today
    return departure_datetime_utc.to_time > time_of_sell + 24.hours  if time_of_sell.hour < WORK_START_HOUR
    return time_of_sell + 4.hours < departure_datetime_utc.to_time if (WORK_START_HOUR...WORK_END_HOUR).include? time_of_sell.hour
    return departure_datetime_utc.to_time > time_of_sell + 24.hours && last_tkt_date > Date.today
  end


  def self.ok_to_sell_sirena departure_datetime_utc, time_of_sell = nil
    time_of_sell ||= Time.now
    time_of_sell + 4.hours < departure_datetime_utc.to_time
  end

  #У пользователя есть как минимум 10 минут, чтобы изучить список
  def self.ok_to_show_sirena departure_datetime_utc
    ok_to_sell_sirena(departure_datetime_utc, Time.now + 20.minutes)
  end

  def self.ok_to_show departure_datetime_utc
    ok_to_sell(departure_datetime_utc, nil, Time.now + 20.minutes)
  end

  #У пользователя есть как минимум 10 минут, чтобы заполнить форму
  def self.ok_to_book_sirena departure_datetime_utc
    ok_to_sell_sirena(departure_datetime_utc, Time.now + 10.minutes)
  end

  def self.ok_to_book departure_datetime_utc, last_tkt_date = nil
    ok_to_sell(departure_datetime_utc, last_tkt_date, Time.now + 10.minutes)
  end

  #сейчас не используется
  def self.nearest_ticketing_time time = nil
    time ||= Time.now
    return time if (WORK_START_HOUR...WORK_END_HOUR).include? time.hour
    return Date.today + WORK_START_HOUR.hours if time.hour < WORK_START_HOUR
    return Date.today + 1.day + WORK_START_HOUR.hours if time.hour >= WORK_END_HOUR
  end

end


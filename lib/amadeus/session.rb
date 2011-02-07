# encoding: utf-8
module Amadeus
  # простой, но надежный как rand(2**31) != rand(2**31) аллокатор сессий
  # обошелся без блокировки таблиц
  class Session < ActiveRecord::Base

  BOOKING = 'MOWR228FA'
  TICKETING = 'MOWR2290Q'
  # логин сюда не работает
  # только для передачи прав доступа
  WORKING = 'MOWR2233B'

  set_table_name 'amadeus_sessions'

  INACTIVITY_TIMEOUT = 10*60
  MAX_SESSIONS = 10

  scope :stale, lambda { where("updated_at < ?", INACTIVITY_TIMEOUT.seconds.ago)}
  scope :busy, where("booking is not null")
  scope :free,
    lambda { where("updated_at >= ? AND booking is null", INACTIVITY_TIMEOUT.seconds.ago)}

  def self.from_token(auth_token)
    session = new
    session.token, session.seq = auth_token.split('|')
    session.seq += 1
    session
  end

  # для продолжения использования сессии между реквестами
  def self.from_booking(booking)
    busy.find_by_booking(booking) or raise("Amadeus session not found or expired")
  end

  def increment
    self.seq += 1
  end

  def session_id
    "#{token}|#{seq}"
  end

  def release
    self.booking = nil
    save
  end

  def self.with_session(previous_session=nil)
    session = previous_session || book
    result = yield session
    session.increment
    result
  rescue Amadeus::Error
    # TODO проверить что нужно увеличивать счетчик в случае разных 91ых ошибок
    session.increment
    raise
  ensure
    # не освобождаем сессию, переданную явно
    session.release if session && !previous_session
  end

  def self.book(office=nil)
    office ||= Amadeus::Session::BOOKING
    logger.debug { "Free sessions count: #{free.count}" }
    booking = rand(2**31)
    free.update_all({:booking => booking}, nil, {:limit => 1})
    session = find_by_booking(booking)
    unless session
      unless session = increase_pool(booking, office)
        raise "somehow can't get new session"
      end
    else
      logger.debug "Reusing session #{session.token}"
    end
    session
  end

  # без параметра создает незарезервированную сессию
  def self.increase_pool(booking=nil, office=nil)
    office ||= Amadeus::Session::BOOKING
    logger.debug "Allocating new amadeus session"
    token = Amadeus::Service.security_authenticate(office)
    session = from_token(token)
    session.booking = booking if booking
    session.office = office
    session.save
    session
  end

  # для кронтасков, скоростью не блещет
  # TODO сделать logout для старых сессий
  def self.housekeep
    stale.destroy_all
    (MAX_SESSIONS-count).times { increase_pool }
  end

  def destroy
    logger.debug "Signing out amadeus session #{token}"
    super
    Amadeus::Service.security_sign_out(self)
  rescue Handsoap::Fault
    # it's ok
  end

  end
end

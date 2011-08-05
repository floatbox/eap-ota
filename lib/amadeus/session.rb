# encoding: utf-8
module Amadeus
  # простой, но надежный как rand(2**31) != rand(2**31) аллокатор сессий
  # обошелся без блокировки таблиц
  class Session < ActiveRecord::Base

  BOOKING = 'MOWR228FA'
  TICKETING = 'MOWR2290Q'
  # логин сюда не работает
  # только для передачи прав доступа
  WORKING = 'MOWR223BB'
  #WORKING = 'MOWR2233B'

  set_table_name 'amadeus_sessions'

  cattr_accessor :logger do
    Rails.logger
  end

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
    return if destroyed?
    self.seq += 1
  end

  def session_id
    "#{token}|#{seq}"
  end

  def release
    return if destroyed?
    logger.info "Amadeus::Session: #{token} released"
    self.booking = nil
    save
  end

  def self.book(office=nil)
    office ||= Amadeus::Session::BOOKING
    logger.info { "Amadeus::Session: free sessions count: #{free.count}" }
    booking = SecureRandom.random_number(2**31)

    # FIXME fucking awesome! AREL simply ignores "limit 1" from some version above
    # free.limit(1).update_all(:booking => booking)
    update_all( "booking = #{booking} WHERE #{free.where_values.join ' AND '} LIMIT 1" )

    session = find_by_booking(booking)
    unless session
      unless session = increase_pool(booking, office)
        raise "somehow can't get new session"
      end
    else
      logger.info "Amadeus::Session: #{session.token} reused (#{session.seq})"
    end
    session
  end

  # без параметра создает незарезервированную сессию
  def self.increase_pool(booking=nil, office=nil)
    office ||= Amadeus::Session::BOOKING
    token = Amadeus::Service.security_authenticate(:office => office).or_fail!.session_id
    session = from_token(token)
    session.booking = booking if booking
    session.office = office
    logger.info "Amadeus::Session: #{session.token} signed in"
    session.save
    session
  end

  # для кронтасков, скоростью не блещет
  def self.housekeep
    stale.destroy_all
    (Conf.amadeus.session_pool_size - count).times { increase_pool }
  end

  # тоже для кронтасков, не разлогинивает, не создает новые
  def self.dirty_housekeep
    stale.delete_all
  end

  def destroy
    logger.info "Amadeus::Session: #{token} signing out (#{seq})"
    super
    Amadeus::Service.new(:session => self).security_sign_out
  rescue Handsoap::Fault
    # it's ok
  end

  end
end


# encoding: utf-8
module Amadeus
  # простой, но надежный как rand(2**31) != rand(2**31) аллокатор сессий
  # обошелся без блокировки таблиц
  class Session

  def self.office_for_alias(al)
    Conf.amadeus.offices.each do |office, settings|
      return office if settings["alias"] == al.to_s
    end
    raise ArgumentError, "no office_id defined for alias #{al}"
  end

  # FIXME избавиться от констант
  BOOKING = office_for_alias(:booking)
  TICKETING = office_for_alias(:ticketing)
  DOWNTOWN = office_for_alias(:downtown)
  ZAGORYE = office_for_alias(:zagorye)
  LVIV = office_for_alias(:lviv)

  cattr_accessor :logger do
    Rails.logger
  end

  cattr_accessor :pool do
    Amadeus::Session::MongoStore
    #Amadeus::Session::ARStore
  end

  cattr_accessor :default_office do
    Conf.amadeus.default_office
  end

  INACTIVITY_TIMEOUT = 10*60
  MAX_SESSIONS = 10

  class << self

    # public
    # вызывается с параметром и без (для класс-методов амадеуса)
    def book(office=nil)
      office ||= default_office
      logger.info { "Amadeus::Session: free sessions count: #{pool.free_count(office)}" }
      find_free_and_book(office) || sign_in(office, true)
    end

    def find_free_and_book(office)
      if record = pool.find_free_and_book(office: office)
        logger.info "Amadeus::Session: #{record.token} reused (#{record.seq}) for #{record.office}"
        from_record(record)
      end
    end

    # без параметра создает незарезервированную сессию
    def sign_in(office, booked=false)
      office ||= default_office
      session_id = Amadeus::Service.security_authenticate(office: office).or_fail!.session_id
      session = new(session_id: session_id, office: office)
      logger.info "Amadeus::Session: #{session.token} signed into #{office}"
      session.increment
      # saves session
      session.booked = booked
      session
    end

    # для кронтасков, скоростью не блещет
    def housekeep
      pool.each_stale(default_office) do |record|
        from_record(record).destroy
      end
      (Conf.amadeus.session_pool_size - pool.free_count(default_office)).times do
        sign_in(default_office)
      end
    end

    # удаляет из хранилища и сессии, используемые другими процессами прямо сейчас.
    # не должно быть проблемой
    # без параметра удаляет сессии во всех офисах
    def delete_all(office=nil)
      if office
        pool.delete_all(office: office)
      else
        pool.delete_all
      end
    end

    def from_record(record)
      session = allocate
      session.record = record
      session
    end

  end

  # instance methods

  def initialize(args={})
    self.record = pool.new(args)
  end

  attr_accessor :record

  delegate :increment,
           :office, :office=,
           :session_id, :session_id=,
           :token, :token=,
           :seq, :seq=,
           :booked?, :booked=,
    to: :record

  # public
  # освобождение сессии (только в поиске?)
  def release
    logger.info "Amadeus::Session: #{token} released"
    record.release
  end

  # public
  def destroy
    logger.info "Amadeus::Session: #{token} signing out (#{seq})"
    record.destroy
    Amadeus::Service.new(:session => self).security_sign_out
  rescue Handsoap::Fault
    # it's ok
  end

  end
end


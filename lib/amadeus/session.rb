# encoding: utf-8
module Amadeus
  # простой, но надежный как rand(2**31) != rand(2**31) аллокатор сессий
  # обошелся без блокировки таблиц
  class Session

  extend Monitoring::Benchmarkable

  cattr_accessor :logger do
    ForwardLogging.new(Rails.logger)
  end

  cattr_accessor :pool do
    Amadeus::Session::RedisStore
    #Amadeus::Session::MongoStore
    #Amadeus::Session::ARStore
  end

  cattr_accessor :default_office do
    Conf.amadeus.default_office
  end

  INACTIVITY_TIMEOUT = 10.minutes
  MAX_SESSIONS = 10

  class << self

    # public
    # вызывается с параметром и без (для класс-методов амадеуса)
    def book(office=nil)
      office ||= default_office
      logger.debug { "Amadeus::Session: free sessions count: #{pool.free_count(office)}" }
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
      benchmark 'amadeus session sign in' do
        office ||= default_office
        session_id = Amadeus::Service.security_authenticate(office: office).or_fail!.session_id
        session = new(session_id: session_id, office: office)
        logger.info "Amadeus::Session: #{session.token} signed into #{office}"
        session.increment
        # saves session
        session.booked = booked

        # вернул костыль для RedisStore, переопределять booked= в RedisStore как-то тупо
        # FIXME не придумал как лучше сделать, разве что отрефакторить и не сохранять на booked=
        if (!booked && pool.eql?(Amadeus::Session::RedisStore))
          # в redis сохраняем только свободные сессии, т.е. !booked
          RedisStore.push_free(session.token, session.seq, session.office)
        end

        session
      end
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
  rescue Amadeus::SoapError
    # it's ok
  end

  end
end


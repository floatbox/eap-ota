class AmadeusSession < ActiveRecord::Base

  TIMEOUT = 180

  def self.from_token(auth_token)
    session = new
    session.token, session.seq = auth_token.split('|')
    session.seq += 1
    #self.last_used = Time.now
    session
  end

  def increment
    #self.last_used = Time.now
    self.seq += 1
  end

  def session_id
    "#{token}|#{seq}"
  end

  def busy?
    !booking.nil?
  end

  def release
    self.booking = nil
    save
  end

  def ready?
    !busy? && !timeout?
  end

  def timeout?
    Time.now - last_used > TIMEOUT
  end

  def self.with_session(previous_session=nil)
    session = previous_session || book
    result = yield session
    session.increment
    result
  rescue Amadeus::AmadeusError
    # TODO проверить что нужно увеличивать счетчик в случае разных 91ых ошибок
    session.increment
    raise
  ensure
    # не освобождаем сессию, переданную явно
    session.release if session && !previous_session
  end

  def self.book
    booking = rand(2**31)
    logger.debug { "Free sessions count: #{count}" }
    update_all({:booking => booking}, {:booking => nil}, {:limit => 1})
    session = find_by_booking(booking)
    unless session
      unless session = increase_pool(booking)
        raise "somehow can't get new session"
      end
    end
    session
  end

  # без параметра создает незарезервированную сессию
  def self.increase_pool(booking=nil)
    token = Amadeus.security_authenticate
    session = from_token(token)
    session.booking = booking if booking
    session.save
    session
  end

  def self.housekeep
    delete_all ["updated_at < ?", TIMEOUT.seconds.ago]
    # allocate more sessions
    #if (count = free_sessions_count) < SAFE_FREE_SESSIONS_COUNT
    #  (SAFE_FREE_SESSIONS_COUNT - count).times { increase_pool }
    #end
  end

  def self.free_sessions_count
    count ["updated_at >= ?", TIMOUT.seconds.ago]
  end
end

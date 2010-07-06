# not thread safe at all!
module AmadeusSessions
  class Session

    TIMEOUT = 180

    def initialize(token)
      @token = token.split('|').first
      @seq = 2
      @last_used = Time.now
    end

    attr_reader :seq, :token, :last_used

    def increment
      @last_used = Time.now
      @seq += 1
    end

    def session_id
      "#{@token}|#{@seq}"
    end

    def book
      @busy = true
    end

    def release
      @busy = false
    end

    def ready?
      !@busy && !timeout?
    end

    def timeout?
      Time.now - @last_used > TIMEOUT
    end

    def self.with_session(previous_session=nil)
      session = previous_session || book
      result = yield session
      session.increment
      result
    rescue Amadeus::AmadeusError
      session.increment
      raise
    ensure
      # не освобождаем сессию, переданную явно
      # session.release if session && !previous_session
      # временная заглушка
      @@pool.delete(session) if session && !previous_session
    end

    @@pool = []
    def self.pool
      @@pool
    end

    def self.book
      if session = @@pool.detect {|s| s.ready? }
        session.book
      else
        unless session = increase_pool
          raise "somehow can't get new session"
        end
        session.book
      end
      session
    end

    def self.increase_pool
      token = Amadeus.security_authenticate
      session = new(token)
      @@pool << session
      session
    end

    def self.housekeep
      @@pool.reject! {|s| s.timeout? }
      # allocate more sessions
    end
  end
end

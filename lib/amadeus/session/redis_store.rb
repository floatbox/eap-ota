# encoding: utf-8

module Amadeus
  class Session

    class PseudoAR < Struct.new(:token, :seq, :office)

      include RedisConnection

      def session_id
        "#{token}|#{seq}"
      end

      def session_id=(sid)
        t, s = sid.split('|')
        # у Struct свои идиосинкразии на присваивание внутри инстанса
        self[:token] = t
        self[:seq] = s.to_i
        sid
      end

      def increment
        Rails.logger.info "INCREMENT"
        Rails.logger.info self
        Rails.logger.info "seq: #{seq}"
        self[:seq] += 1
      end

      # заглушки для совместимости с текущим интерфейсом
      def booked?
        false
      end

      def booked=(dontcare)
      end

      def release
      end

    end

    class RedisStore

      KEY_BASE = "amadeus_sessions::#{Conf.amadeus.env}"

      attr_accessor :session

      delegate \
        :office, :office=,
        :seq, :seq=,
        :token, :token=,
        :increment,
        :booked?, :booked=,
        :session_id, :session_id=,
        to: :session

      extend RedisConnection

      def initialize(args)
        Rails.logger.info "args: #{args}"
        token, seq = args[:session_id].split('|')
        seq = seq.to_i
        office = args[:office]
        @session = PseudoAR.new(token, seq, office)
        Rails.logger.info "@session: #{@session}"
        super()
      end

      def self.free_by_office(office)
        Rails.logger.info __method__
        "#{KEY_BASE}::free::#{office}"
      end

      def self.by_token(token)
        Rails.logger.info __method__
        "#{KEY_BASE}::#{token}"
      end

      def self.push_free(token, seq, office)
        Rails.logger.info __method__
        redis.multi do
          ttl_key = by_token(token)
          redis.pipelined do
            redis.lpush(free_by_office(office), token)
            redis.set(ttl_key, seq)
          end
          # а теперь ставим ttl на ключик с токеном
          redis.expire(ttl_key, Amadeus::Session::INACTIVITY_TIMEOUT)
        end
      end

      def self.pop_free(office)
        Rails.logger.info __method__
        free_tokens = free_by_office(office)

        return unless redis.llen(free_tokens).nonzero?

        token = redis.rpop(free_tokens)
        # если сессия не заэкспайрена - возвращаем,
        # иначе - берем следующую
        key = by_token(token)
        if seq = redis.get(key)
          redis.expire(key, Amadeus::Session::INACTIVITY_TIMEOUT)
          PseudoAR.new(token, seq.to_i, office)
        else
          Rails.logger.info "RETRY"
          pop_free(office)
        end
      end

      # returns nil if no free session available
      def self.find_free_and_book(args)
        Rails.logger.info __method__
        args.assert_valid_keys :office
        pop_free(args[:office])
      end

      def self.free_count(office)
        Rails.logger.info __method__
        redis.llen(free_by_office(office))
      end

      def self.delete_all(args={})
        Rails.logger.info __method__
        args.assert_valid_keys :office
        redis.keys("#{KEY_BASE}*").each do |key|
          redis.pipelined do
            redis.del(key)
          end
        end
      end

      def release
        RedisStore.push_free(session.token, session.seq, session.office)
      end

      # заглушки, нужны только для совместимости с текущим интерфейсом

      def self.each_stale(office)
        Rails.logger.info __method__
        []
      end

      def self.default_condition
        {}
      end

    end
  end
end

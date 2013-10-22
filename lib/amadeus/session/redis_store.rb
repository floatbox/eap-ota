# encoding: utf-8

module Amadeus
  class Session

    class PseudoSession < Struct.new(:token, :seq, :office)

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
        Rails.logger.info __method__
        Rails.logger.info "seq: #{seq}"
        self[:seq] += 1
      end

      # сейвится реально в release и booked=
      def release
        Rails.logger.info __method__
        RedisStore.push_free(token, seq, office)
      end

      def booked=(booked)
        RedisStore.pop_free(office) if booked
      end

      # заглушки для совместимости с текущим интерфейсом
      attr_accessor :booked

      def book
        booked = true
      end

      def booked?
        !!booked
      end

      def stale?
        false
      end

      def free?
        true
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
        :booked?, :booked=, :book,
        :session_id, :session_id=,
        :free?, :stale,
        to: :session

      extend RedisConnection

      def initialize(args = {})
        Rails.logger.info "args: #{args}"
        if session_id = args[:session_id]
          token_, seq_num = args[:session_id].split('|')
          seq_num = seq_num.to_i
        else
          token_ = args[:token]
          seq_num = args[:seq]
        end
        office_id = args[:office]
        @session = PseudoSession.new(token_, seq_num, office_id)
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

        unless redis.llen(free_tokens).nonzero?
          Rails.logger.info "returning nil!"
          return
        end

        token = redis.rpop(free_tokens)
        Rails.logger.info "token: #{token}"
        # если сессия не заэкспайрена - возвращаем,
        # иначе - берем следующую
        key = by_token(token)
        Rails.logger.info "key: #{key}"
        if seq = redis.get(key)
          Rails.logger.info "seq: #{seq}"
          redis.expire(key, Amadeus::Session::INACTIVITY_TIMEOUT)
          PseudoSession.new(token, seq.to_i, office)
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

      # то тут, то там
      # FIXME: надо этот метод убирать из api сессий
      # и вызывать только на самой сессии, т.е. PseudoSession
      def release
        Rails.logger.info __method__
        Rails.logger.info "RELEASE 1"
        session.release
      end

      # заглушки, нужны только для совместимости с текущим интерфейсом

      def self.each_stale(office)
        Rails.logger.info __method__
        []
      end

      def self.default_condition
        {}
      end

      # для тестов
      def save!
        RedisStore.push_free(token, seq, office)
      end

      # нужен только для housekeep => не нужен для RedisStore вообще
      def destroy
      end

    end
  end
end

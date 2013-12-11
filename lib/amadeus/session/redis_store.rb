# encoding: utf-8

module Amadeus
  class Session

    # надо эту штуку вынести выше в Amadeus::Session из Store-ов
    class PseudoSession < Struct.new(:token, :seq, :office)

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
        self[:seq] += 1
      end

      attr_accessor :booked

      # сейвится реально в release и booked=,
      # но второй не нужен
      def release
        RedisStore.push_free(token, seq, office)
      end

      # затычка
      def destroy
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
        :destroy,
        to: :session

      def initialize(args = {})
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

      def self.redis
        RedisClient
      end

      def self.by_office(office)
        "#{KEY_BASE}::free::#{office}"
      end

      def self.by_token(token)
        "#{KEY_BASE}::#{token}"
      end

      def self.push_free(token, seq, office)
        redis.multi do
          ttl_key = by_token(token)
          redis.pipelined do
            redis.lpush(by_office(office), token)
            redis.set(ttl_key, seq)
          end
          # а теперь ставим ttl на ключик с токеном
          redis.expire(ttl_key, Amadeus::Session::INACTIVITY_TIMEOUT)
          # можно еще ltrim тут юзать, чтобы лишние элементы убирать
          # и юзать своего рода capped list, но на масштабах только усложнит
        end
      end

      def self.pop_free(office)
        free_tokens = by_office(office)

        current_sessions = redis.llen(free_tokens)
        Monitoring.gauge(
          service: 'redis_session_pool',
          metric: current_sessions
        )

        unless current_sessions.nonzero?
          Rails.logger.info "no sessions in redis pool!"
          return
        end

        token = redis.rpop(free_tokens)
        # если сессия не заэкспайрена - возвращаем,
        # иначе - берем следующую
        key = by_token(token)
        if seq = redis.get(key)
          redis.expire(key, Amadeus::Session::INACTIVITY_TIMEOUT)
          PseudoSession.new(token, seq.to_i, office)
        else
          pop_free(office)
        end
      end

      # returns nil if no free session available
      def self.find_free_and_book(args)
        args.assert_valid_keys :office
        pop_free(args[:office])
      end

      def self.free_count(office)
        (redis.keys("#{KEY_BASE}::*").count || 1) - 1
      end

      def self.delete_all(args={})
        office = args[:office]
        key_mask = if office
          RedisStore.by_office(office)
        else
          KEY_BASE + "*"
        end
        keys = redis.keys(key_mask)
        redis.pipelined do
          keys.each do |key|
            redis.del(key)
          end
        end
      end

      def release
        session.release
      end

      # заглушки, нужны только для совместимости с текущим интерфейсом

      def self.each_stale(office)
        []
      end

      def self.default_condition
        {}
      end

      # для тестов
      def save!
        RedisStore.push_free(token, seq, office)
      end

    end
  end
end

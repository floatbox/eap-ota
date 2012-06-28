# encoding: utf-8
module Amadeus
  class Session
    class ARStore < ActiveRecord::Base

      self.table_name = 'amadeus_sessions'

      # FIXME надо указать свободность сессии в stale?
      # есть риск, что будет попытка разлогинить сессию при долгом кронтаске
      # (find_free_and_book не трогает updated_at)
      scope :stale, lambda { where("updated_at < ?", Amadeus::Session::INACTIVITY_TIMEOUT.seconds.ago)}
      scope :busy, where("booking is not null")
      scope :free, lambda { where("updated_at >= ? AND booking is null", Amadeus::Session::INACTIVITY_TIMEOUT.seconds.ago)}
      scope :for_office, lambda { |office_id| where( office: office_id ) }

    public

      # returns nil if no free session available
      def self.find_free_and_book(args)
        args.assert_valid_keys :office
        booking = new_uid
        free.for_office(args[:office]).limit(1).update_all(booking: booking)
        find_by_booking(booking)
      end

      def self.free_count(office)
        free.for_office(office).count
      end

      def self.each_stale(office, &block)
        stale.for_office(office).each(&block)
      end

      # db accessors
      # token: string
      # seq: integer
      # office: string
      #
      # updated_at: datetime
      # booking: integer (для маркировки резервирования сессии)

      def session_id=(auth_session_id)
        self.token, seq = auth_session_id.split('|')
        self.seq = seq.to_i
      end

      def session_id
        "#{token}|#{seq}"
      end

      def increment
        # зачем-то инкрементим даже в дестроейд записи, а это не позволяет активрекорд
        return if destroyed?
        self.seq += 1
      end

      def book
        self.booking ||= new_uid
        save
      end

      def release
        self.booking = nil
        save
      end

      def booked=(booking_state)
        booking_state ? book : release
      end

      def booked?
        !! booking
      end

      def free?
        ! booked?
      end

      def stale?
        updated_at <= ::Amadeus::Session::INACTIVITY_TIMEOUT.seconds.ago
      end

      module BadUID
        # sufficiently random. or not?
        private
        def new_uid
          SecureRandom.random_number(2**31)
        end
      end
      include BadUID
      extend BadUID

    end
  end
end

# encoding: utf-8
module Amadeus
  class Session
    class MongoStore

      cattr_accessor :collection do
        Mongoid.master['amadeus_sessions']
      end

    public

      # returns nil if no free session available
      def self.find_free_and_book(args)
        args.assert_valid_keys :office
        # FIXME: добавить sort:, чтобы равномерно использовать сессии
        doc = collection.find_and_modify(
          query: free_condition.merge(office: args[:office]),
          update: {:$set => {booked: true}},
          new: true
        )
        new(doc: doc) if doc
      end

      def self.free_count(office)
        collection.count(query: free_condition.merge(office: office))
      end

      def self.each_stale(office)
        collection.find( query: stale_condition.merge(office: office) ).each do |doc|
          yield new(doc: doc)
        end
      end

      include KeyValueInit
      def initialize(args)
        @doc = args.delete(:doc) || {"booked" => false}
        super
      end

      # accessors
      def token
        @doc["_id"]
      end

      def token=(token)
        @doc["_id"] = token
      end

      def seq
        @doc["seq"]
      end

      def seq=(seq)
        @doc["seq"] = seq
      end

      def office
        @doc["office"]
      end

      def office=(office)
        @doc["office"] = office
      end

      def session_id=(auth_session_id)
        self.token, seq = auth_session_id.split('|')
        self.seq = seq.to_i
      end

      def session_id
        "#{token}|#{seq}"
      end

      def increment
        @doc["seq"] += 1
      end

      def book
        @doc["booked"] = true
        save
      end

      def release
        @doc["booked"] = false
        save
      end

      def destroy
        collection.remove( _id: token )
      end

      def booked=(booking_state)
        booking_state ? book : release
      end

      def booked?
        @doc["booked"]
      end

    private

      def save
        @doc["updated_at"] = Time.now
        collection.save( @doc )
      end

      def self.free_condition
        {
          booked: false,
          updated_at: { :$gt => Amadeus::Session::INACTIVITY_TIMEOUT.seconds.ago.utc }
        }
      end

      def self.stale_condition
        {
          # FIXME сделать как в ARStore?..
          # booked: false,
          updated_at: { :$lte => Amadeus::Session::INACTIVITY_TIMEOUT.seconds.ago.utc }
        }
      end

    end
  end
end

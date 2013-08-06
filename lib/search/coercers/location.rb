# encoding: utf-8

module Search
  module Coercers
    class Location < Virtus::Attribute::Object
      class LocationWriter < Virtus::Attribute::Writer::Coercible
        def coerce(value)
          case value
          when String then coerce_from_string(value)
          when ActiveRecord::Base then value
          else return
          end
        end

        def coerce_from_string(value)
          ::Location[value]
        rescue CodeStash::NotFound
          return Completer.object_from_string(value)
        end
      end

      def self.writer_class(*)
        LocationWriter
      end
    end
  end
end


# encoding: utf-8

module Search
  module Coercers
    class Location < Virtus::Attribute::Object
      class LocationWriter < Virtus::Attribute::Writer::Coercible
        def coerce(value)
          case value
          when String then Completer.object_from_string(value)
          when ActiveRecord::Base then value
          else return
          end
        end
      end

      def self.writer_class(*)
        LocationWriter
      end
    end
  end
end


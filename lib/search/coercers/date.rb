# encoding: utf-8

module Search
  module Coercers
    class Date < Virtus::Attribute
      def coerce_string(value)
        case value
        # amadeus style
        when /^\d{6}$/
          ::Date.strptime(value, '%d%m%y')
        else
          ::Date.parse(value)
        end
      end

      def coerce(value)
        case value
        when String then coerce_string(value)
        when ::Date then value
        else return
        end
      ensure
      end
    end
  end
end


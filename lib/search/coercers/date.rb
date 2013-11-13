# encoding: utf-8

module Search
  module Coercers
    class Date < Virtus::Attribute
      def coerce_string(value)
        case value
        when /^\d{6}$/ then ::Date.strptime(value, '%d%m%y')
        when /^\d{2}\-\d{2}\-\d{2,4}$/ then ::Date.strptime(value, '%d-%m-%y')
        end
      end

      def coerce(value)
        case value
        when String then coerce_string(value)
        when Date then value
        else return
        end
      ensure
      end
    end
  end
end


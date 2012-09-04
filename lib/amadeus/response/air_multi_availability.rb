# encoding: utf-8
module Amadeus
  module Response
    class AirMultiAvailability < Amadeus::Response::Base
      def availability_summary
        xpath('//r:infoOnClasses/r:productClassDetail').inject({}) do |memo, info|
          memo.merge({info.xpath('r:serviceClass').to_s => info.xpath('r:availabilityStatus').to_s})
        end
      end

      def lowest_avaliable_booking_class
        availability_summary.to_a.reverse.each do |booking_class, availability|
          return booking_class if availability.to_i > 0
        end
      end
    end
  end
end


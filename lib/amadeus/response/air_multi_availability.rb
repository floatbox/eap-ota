# encoding: utf-8
module Amadeus
  module Response
    class AirMultiAvailability < Amadeus::Response::Base
      def availability_summary
        xpath('//r:infoOnClasses/r:productClassDetail').inject({}) do |memo, info|
          memo.merge({info.xpath('r:serviceClass').to_s => info.xpath('r:availabilityStatus').to_s})
        end
      end
    end
  end
end


module Amadeus
  module Request
    class AirSellFromRecommendation < Amadeus::Request::Base
      attr_accessor :seat_total, :segments, :recommendation

    end
  end
end

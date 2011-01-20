module Amadeus
  module Request
    class AirSellFromRecommendation < Amadeus::Request::Base
      attr_accessor :people_count, :segments

    end
  end
end
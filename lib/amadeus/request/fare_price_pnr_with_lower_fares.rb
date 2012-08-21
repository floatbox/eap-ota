module Amadeus
  module Request
    class FarePricePNRWithLowerFares < Amadeus::Request::Base
      attr_accessor :cabin
    end
  end
end

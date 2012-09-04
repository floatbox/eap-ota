module Amadeus
  module Request
    class QueuePlacePNR < Amadeus::Request::Base
      attr_accessor :number
    end
  end
end
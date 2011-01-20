module Amadeus
  module Request
    class PNRRetrieve < Amadeus::Request::Base
      attr_accessor :number
    end
  end
end
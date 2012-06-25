module Amadeus
  module Request
    class PNRTransferOwnership < Amadeus::Request::Base
      attr_accessor :number, :office_id
    end
  end
end

module Amadeus
  module Request
    # CommandCryptic: RP
    class PNRTransferOwnership < Amadeus::Request::Base
      attr_accessor :number, :office_id
    end
  end
end

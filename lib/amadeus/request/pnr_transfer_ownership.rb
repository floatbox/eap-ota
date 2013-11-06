module Amadeus
  module Request
    # CommandCryptic: RP
    class PNRTransferOwnership < Amadeus::Request::Base
      attr_accessor :number, :office_id

      def summary
        [number, office_id].join(' ')
      end
    end
  end
end

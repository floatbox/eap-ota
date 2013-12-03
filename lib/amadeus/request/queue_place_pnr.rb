module Amadeus
  module Request
    class QueuePlacePNR < Amadeus::Request::Base
      attr_accessor :number, :queue, :category, :office_id

      def summary
        [number, queue, category, office_id].join(' ')
      end
    end
  end
end

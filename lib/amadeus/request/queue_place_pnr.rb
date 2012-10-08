module Amadeus
  module Request
    class QueuePlacePNR < Amadeus::Request::Base
      attr_accessor :number, :queue, :category, :office_id
    end
  end
end
module Amadeus
  module Request
    class TicketCreateTSTFromPricing < Amadeus::Request::Base
      attr_accessor :fares_count
    end
  end
end
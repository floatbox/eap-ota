module Amadeus
  module Request
    class AirRebookAirSegment < Amadeus::Request::Base
      attr_accessor :flights, :old_booking_classes, :new_booking_classes
    end
  end
end

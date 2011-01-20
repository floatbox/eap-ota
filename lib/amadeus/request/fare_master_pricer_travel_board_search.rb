module Amadeus
  module Request
    class FareMasterPricerTravelBoardSearch < Amadeus::Request::Base
      attr_accessor :people_count, :cabin, :nonstop, :segments

      def initialize(opts)
        if opts.is_a? Hash
          super
        else
          @people_count = opts.real_people_count
          @cabin = opts.cabin
          @segments = opts.form_segments
        end
      end

    end
  end
end

module Amadeus
  module Request
    class FareMasterPricerTravelBoardSearch < Amadeus::Request::Base
      attr_accessor :people_count, :nonstop, :segments, :cabin, :suggested_limit, :search_around

      def initialize(*args)
        unless args.first.is_a?(Hash)
          form = args.shift
          @people_count = form.tariffied
          @cabin = form.cabin
          @segments = form.segments
        end
        super *args
      end

      def suggested_limit
         @suggested_limit || 250
      end

    end
  end
end


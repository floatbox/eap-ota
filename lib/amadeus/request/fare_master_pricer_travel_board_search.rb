module Amadeus
  module Request
    class FareMasterPricerTravelBoardSearch < Amadeus::Request::Base
      attr_accessor :people_count, :nonstop, :segments, :cabin, :lite, :suggested_limit, :complex_route

      def initialize(*args)
        unless args.first.is_a?(Hash)
          form = args.shift
          @people_count = form.real_people_count
          @cabin = form.cabin
          @segments = form.form_segments
          @complex_route = form.complex_route?
        end
        super *args
      end

      def suggested_limit
         @suggested_limit || (lite ? Conf.amadeus.recommendations_lite : Conf.amadeus.recommendations_full)
      end

    end
  end
end


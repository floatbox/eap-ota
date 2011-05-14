module Amadeus
  module Request
    class FareMasterPricerTravelBoardSearch < Amadeus::Request::Base
      attr_accessor :people_count, :nonstop, :segments, :cabin

      def initialize(opts, lite=false)
        if opts.is_a? Hash
          super
        else
          @people_count = opts.real_people_count
          @cabin = opts.cabin
          @segments = opts.form_segments
          @how_many = Conf.amadeus.recommendations_lite if lite
        end
      end

    end
  end
end


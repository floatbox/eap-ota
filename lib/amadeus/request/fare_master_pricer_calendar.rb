module Amadeus
  module Request
    class FareMasterPricerCalendar < Amadeus::Request::FareMasterPricerTravelBoardSearch
      def self.from_pricer_form(pricer_form)
        new(:people_count => pricer_form.real_people_count, 
            :cabin => pricer_form.cabin, 
            :nonstop => pricer_form.nonstop, 
            :segments => pricer_form.form_segments)
      end
    end
  end
end
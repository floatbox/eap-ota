# encoding: utf-8
module Sirena
  module Request
    class Pricing < Sirena::Request::Base
      CabinsMatch = {"Y"=>"Э", "F"=>"П", "C"=>"Б"}
      attr_accessor :passengers, :segments
      # это должно быть здесь, я уже всеоо придумал
      def initialize(form, recommendation = nil)
        @passengers = []
        if form.people_count[:adults] > 0
          @passengers << {:code => "ААА", :count => form.people_count[:adults]}
        end
        # я не знаю, откуда брать возраст в реальной жизни,
        # но он - необходимый параметр, поэтому от балды пока
        if form.people_count[:children] > 0
          @passengers << {:code=>"РБГ", :count => form.people_count[:children], :age => 5}
        end
        if form.people_count[:infants] > 0
          @passengers << {:code=>"РМГ", :count => form.people_count[:infants], :age => 1 }
        end

        @segments = recommendation.blank? ? form.form_segments.collect { |fs|
          { :departure => fs.from_iata,
            :arrival => fs.to_iata,
            :date => sirena_date(fs.date),
            :baseclass => CabinsMatch[form.cabin] || "Э" # это плохо,плохо,плохо
          }
        }: recommendation.flights.collect{|flight|
          i ||= -1
          { :departure => flight.departure_iata,
            :arrival=> flight.arrival_iata,
            :company=> flight.operating_carrier_iata,
            :num=>flight.flight_number,
            :date => sirena_date(flight.departure_date),
            :subclass => recommendation.booking_classes[i+=1]
          }
        }
      end

    end
  end
end

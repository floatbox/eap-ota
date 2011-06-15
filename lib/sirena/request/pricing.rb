# encoding: utf-8
module Sirena
  module Request
    class Pricing < Sirena::Request::Base
      CabinsMatch = {"Y"=>"Э", "F"=>"П", "C"=>"Б"}
      attr_accessor :passengers, :segments, :timeout, :recommendation, :lite, :suggested_timeout

      # FIXME не стоит ли увеличить
      def timeout
        suggested_timeout
      end

      def priority
        if lite
          0
        elsif !recommendation
          1
        else
          2
        end
      end

      def initialize(*args)
        unless args.first.is_a?(Hash)
          form = args.shift
          @passengers = []
          if form.people_count[:adults] > 0
            @passengers << {:code => "ААА", :count => form.people_count[:adults]}
          end
          # ААА - взрослый, РБГ - ребенок, РМГ - младенец, РВГ - младенец с местом
          # CHILD и INFANT, видимо, сами подбирают категории с учетом необходимости мест,
          # но требуют возраст
          # FIXME выбрать один из методов
          if form.people_count[:children] > 0
            @passengers << {:code=>"CHILD", :count => form.people_count[:children], :age => 5}
          end
          if form.people_count[:infants] > 0
            @passengers << {:code=>"INFANT", :count => form.people_count[:infants], :age => 1 }
          end
        end
        super *args

        @segments =
          if recommendation
            recommendation.flights.collect do |flight|
              { :departure => flight.departure_iata,
                :arrival=> flight.arrival_iata,
                :company=> flight.marketing_carrier_iata,
                :num=>flight.flight_number,
                :date => sirena_date(flight.departure_date),
                :subclass => recommendation.booking_class_for_flight(flight)
              }
            end
          else
            form.form_segments.collect do |fs|
              { :departure => fs.from_iata,
                :arrival => fs.to_iata,
                :date => sirena_date(fs.date),
                :baseclass => CabinsMatch[form.cabin] || "Э" # это плохо,плохо,плохо
              }
            end
          end
      end

      def suggested_timeout
        @suggested_timeout || (lite ? Conf.sirena.timeout_lite : 150)
      end
    end
  end
end

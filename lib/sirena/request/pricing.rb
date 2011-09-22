# encoding: utf-8
module Sirena
  module Request
    class Pricing < Sirena::Request::Base
      CabinsMatch = {"Y"=>"Э", "F"=>"П", "C"=>"Б"}
      attr_accessor :passengers, :segments, :timeout, :recommendation, :lite, :suggested_timeout, :given_passengers

      # FIXME не стоит ли увеличить
      def timeout
        #suggested_timeout
        160
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

        @passengers = []
        unless args.first.is_a?(Hash)
          form = args.shift
          determine_passengers_codes_for_priceform(form)
        end
        super *args
        if given_passengers
          determine_passengers_codes_for_recommendation
        end

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
            form.segments.collect do |fs|
              { :departure => fs.from_iata,
                :arrival => fs.to_iata,
                :date => sirena_date(fs.date),
                :baseclass => CabinsMatch[form.cabin] || "Э" # это плохо,плохо,плохо
              }
            end
          end
      end

      def suggested_timeout
        @suggested_timeout || (lite ? Conf.sirena.timeout_lite : Conf.sirena.timeout_full)
      end

      private

        def determine_passengers_codes_for_priceform(form)
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

        def determine_passengers_codes_for_recommendation
          @given_passengers.each {|p| count_people(p.birthdate)}
          @passengers << {:code => "ААА", :count => @adult_counter.to_i}
          if @children_counter
            @passengers << {:code => "CHILD", :count => @children_counter.to_i, :age => 5}
          end
          if @infant_counter
            @passengers << {:code => "INFANT", :count => @infant_counter.to_i, :age =>1}
          end
          @passengers.compact!
        end

        def count_people (birthdate)
            debugger
            last_flight = @recommendation.flights.last
            string_dep_date = sirena_date(last_flight.departure_date)
            departure_date = Date.parse(string_dep_date)
            diff = departure_date.year - birthdate.year
            if diff < 2
              @infant_counter=+1
            elsif diff < 13
              @children_counter=+1
            else
              @adult_counter=+1
            end
        end

    end
  end
end


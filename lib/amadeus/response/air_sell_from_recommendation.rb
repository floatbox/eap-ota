# encoding: utf-8
module Amadeus
  module Response
    class AirSellFromRecommendation < Amadeus::Response::Base

      # FIXME нужно разобраться со statusCode - когда все хорошо, а когда - нет
      # возможно, не только OK подходит
      def segments_confirmed?
        segments_status_codes.uniq == ['OK']
      end

      def segments_status_codes
        xpath('//r:segmentInformation/r:actionDetails/r:statusCode').every.to_s
      end

      # сомнительный способ
      def success?
        segments_confirmed?
      end

      def error_message
        "segments' status codes: #{segments_status_codes}" unless success?
      end

      # апдейтит недостающую инфу в рекомендации
      # FIXME работает ли на сложных маршрутах?
      def fill_itinerary!(segments)
        xpath('//r:itineraryDetails').zip(segments) do |it_det, segment|
          it_det.xpath('r:segmentInformation').zip(segment.flights) do |fl, flight|
            parse_flight(fl, flight)
          end
        end
      end

      private

      def parse_flight(fl, flight)
        #flight.marketing_carrier_iata ||= fl.xpath("r:flightDetails/r:companyDetails/r:marketingCompany").to_s
        flight.departure_term = fl.xpath("r:apdSegment/r:departureStationInfo/r:terminal").to_s
        flight.arrival_term =   fl.xpath("r:apdSegment/r:arrivalStationInfo/r:terminal").to_s

        flight.departure_time = '%04d' % fl.xpath("r:flightDetails/r:flightDate/r:departureTime").to_i
        flight.arrival_time =   '%04d' % fl.xpath("r:flightDetails/r:flightDate/r:arrivalTime").to_i

        flight.equipment_type_iata = fl.xpath("r:apdSegment/r:legDetails/r:equipment").to_s
        flight.technical_stop_count = fl.xpath("r:apdSegment/r:legDetails/r:numberOfStops").to_i

        if fl.xpath("r:flightDetails/r:flightDate/r:arrivalDate").present?
          # такое не бывает в данном запросе
          flight.arrival_date = fl.xpath("r:flightDetails/r:flightDate/r:arrivalDate").to_s
        elsif date_variation = fl.xpath("r:flightDetails/r:flightDate/r:dateVariation").to_i
          flight.arrival_date = shift_date(flight.departure_date, flight.departure_time, flight.arrival_time, date_variation, flight.technical_stop_count)
        else
          flight.arrival_date = flight.departure_date
        end
      end

      def shift_date(departure_date, departure_time, arrival_time, date_variation, stops)
        # по каким-то странным причинам сдвиг назад по дате передается без знака. эвристика против мистики!
        if date_variation == 1 && stops == 0 && (departure_time < arrival_time)
          date_variation = -date_variation
        end
        (DateTime.strptime( departure_date, '%d%m%y' ) + date_variation.days).strftime('%d%m%y')
      end

    end
  end
end

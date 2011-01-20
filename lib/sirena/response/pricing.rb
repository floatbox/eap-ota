# encoding: utf-8
module Sirena
  module Response
    class Pricing < Sirena::Response::Base

      attr_accessor :flights, :recommendations

      # вот это все фигово очень, но переписывать боязно
      def initialize(*)
        super
        self.flights = {}
        xpath("//pricing/flight").each do |fi|
          h = parse_flight(fi);
          flights[h[0]]=h[1]
        end

        self.recommendations = xpath("//pricing/variant").map do |rec|
          parse_recommendation(rec, flights)
        end
      end

      def parse_recommendation(rec, flights)
        booking_classes = [] # тут я думаю, что это классы мест, которые бронируются. права ли я?
        variants = rec.xpath("flights").map{|variant|
          time = ""
          ff = variant.xpath("flight").map{|fi|
            id = fi.attribute("id") && fi.attribute("id").value
            cl = fi.attribute("subclass") && fi.attribute("subclass").value
            booking_classes << cl if cl
            time = flights[id][:time] if time.blank?
            flights[id][:flight]
          }
          # eft = estimated flight time!
          segments = [Segment.new(:eft=>time, :flights=>ff)]
          Variant.new( :segments => segments )
        }

        fare = rec.xpath("direction/price/fare")[0].text.to_f
        total = rec.xpath("direction/price/total")[0].text.to_f
        Recommendation.new(
          :price_fare => fare,
          :price_tax => total - fare,
          :variants => variants,
          :validating_carrier_iata => "",
          :suggested_marketing_carrier_iatas => [],
          :additional_info => "",
          :cabins => [],
          :booking_classes => booking_classes
        )
      end

      def parse_flight(fi)
        dep_iata = fi.xpath("origin").text
        arr_iata = fi.xpath("destination").text
        # Здесь должно быть что-то, что конвертировало бы русское в английское
        dep_iata = convert_to_en(dep_iata)
        arr_iata = convert_to_en(arr_iata)
        f = Flight.new(
          :operating_carrier_iata => fi.xpath("company").text,
          :marketing_carrier_iata => fi.xpath("company").text,
          :departure_iata =>         dep_iata,
          :departure_term =>         fi.xpath("origin").attribute("terminal") && fi.xpath("origin").attribute("terminal").value,
          :arrival_iata =>           arr_iata,
          :arrival_term =>           fi.xpath("destination").attribute("terminal") && fi.xpath("destination").attribute("terminal").value,
          :flight_number =>          fi.xpath("num").text,
          :arrival_date =>           fi.xpath("arrvdate").text.gsub(".", ""),
          :arrival_time =>           to_amadeus_time(fi.xpath("arrvtime").text),
          :departure_date =>         fi.xpath("deptdate").text.gsub(".", ""),
          :departure_time =>         to_amadeus_time(fi.xpath("depttime").text),
          :equipment_type_iata =>    "", # что это?
          :technical_stops => [] #не нашла, есть ли там информация на эту тему. скорее нет
        )
        id = fi.attribute("id") && fi.attribute("id").value
        [id, {:flight=>f, :time=>fi.xpath("flightTime").text}]
      end

      def to_amadeus_time(str)
        if str.length < 5
          str="0"+str
        end
        str.gsub(":", "")
      end

      def convert_to_en(str)
        if str[0] >= "A"[0] && str[0] <= "Z"[0]
          str
        else
          {"ДМД"=>"DME", "ПЛК"=>"LED", "ШРМ"=>"SVO", 
           "ВНК"=>"VKO", "ЦДГ"=>"CDG"}[str] || "SCU"
        end
      end
    end
  end
end

# encoding: utf-8
module Sirena
  module Response
    class Pricing < Sirena::Response::Base

      attr_accessor :flights, :recommendations

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
          time = 0
          prev_arr = ""
          ff = variant.xpath("flight").map{|fi|
            id = fi.attribute("id") && fi.attribute("id").value
            cl = fi.attribute("subclass") && fi.attribute("subclass").value
            booking_classes << cl if cl
            time += flights[id][:time]
            time +=(flights[id][:departure]-prev_arr).to_i/60 if !prev_arr.blank?
            prev_arr=flights[id][:arrival]
            flights[id][:flight]
          }
          # eft = estimated flight time!
          segments = [Segment.new(:eft=>(time/60).to_s+":"+"%02i".%(time % 60), :flights=>ff)]
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
        dep = Time.parse(fi.xpath("deptdate").text+" "+fi.xpath("depttime").text)
        arr = Time.parse(fi.xpath("arrvdate").text+" "+fi.xpath("arrvtime").text)
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
          :equipment_type_iata =>    fi.xpath("airplane").text, # иногда кириллица!
          :technical_stops => [] #не нашла, есть ли там информация на эту тему. скорее нет
        )
        time = fi.xpath("flightTime").text
        if !time.blank?
          scanned = time.scan(/(([0-9]+):)?([0-9]+):([0-9]+)/)[0]
          time = scanned[1].to_i*1440+scanned[2].to_i*60+scanned[3].to_i
        end
        id = fi.attribute("id") && fi.attribute("id").value
        [id, {:flight=>f, :time=>time.to_i, :departure=>dep, :arrival=>arr}]
      end

      def to_amadeus_time(str)
        if str.length < 5
          str="0"+str
        end
        str.gsub(":", "")
      end
    end
  end
end

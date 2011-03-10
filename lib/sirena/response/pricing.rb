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
        end.compact
      end

      def parse_recommendation(rec, flights)
        booking_classes = []
        cabins = []
        first_variant = true
        variants = rec.xpath("flights").map{|variant|
          if variant.attribute("et_possible") && variant.attribute("et_possible").value != 'true'
            next
          end
          time = 0
          prev_arr = ""
          prev_segment_num = ""
          segments = []
          segment = nil
          variant.xpath("flight").each{|fi|
            if prev_segment_num!=fi.attribute("iSegmentNum").text
              if !prev_segment_num.blank?
                segment.eft = (time/60).to_s+":"+"%02i".%(time % 60)
                time = 0
                prev_arr = ""
              end
              segment = Segment.new :flights=>[]
              segments << segment
              prev_segment_num=fi.attribute("iSegmentNum").text
            end
            id = fi.attribute("id") && fi.attribute("id").value
            cl = fi.attribute("subclass") && fi.attribute("subclass").value
            base_cl = fi.attribute("baseclass") && fi.attribute("baseclass").value
            if first_variant
              booking_classes << cl if cl
              cabins << {"Э"=>"Y", "Б"=>"C", "П"=>"F"}[base_cl] || base_cl
            end
            time += flights[id][:time]
            time +=(flights[id][:departure]-prev_arr).to_i/60 if !prev_arr.blank?
            prev_arr=flights[id][:arrival]
            segment.flights << flights[id][:flight]
            first_variant = false
          }
          # eft = estimated flight time!
          segment.eft = (time/60).to_s+":"+"%02i".%(time % 60)
          Variant.new( :segments => segments )
        }.compact

        fare = rec.xpath("direction/price/fare").sum{|elem| elem.text.to_f}
        total = rec.xpath("direction/price/total").sum{|elem| elem.text.to_f}

        Recommendation.new(
          :source => "sirena",
          :price_fare => fare,
          :price_tax => total - fare,
          :variants => variants,
          :validating_carrier_iata => "",
          :suggested_marketing_carrier_iatas => [],
          :additional_info => "",
          :cabins => booking_classes,
          :booking_classes => booking_classes
        ) unless variants.blank?
      end

      def parse_flight(fi)
        dep_iata = fi.xpath("origin").text
        arr_iata = fi.xpath("destination").text
        # без insert неправильно прасится дата
        dep = Time.parse((fi.xpath("deptdate").text+" "+fi.xpath("depttime").text).insert(6, "20"))
        arr = Time.parse((fi.xpath("arrvdate").text+" "+fi.xpath("arrvtime").text).insert(6, "20"))
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
    end
  end
end

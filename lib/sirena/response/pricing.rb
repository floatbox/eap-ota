module Sirena
  module Response
    class Pricing
      class << self
        # какое-то тупое название
        def response(doc)
          flights = {}
          doc.xpath("//pricing/flight").each{|fi| h = parse_flight(fi); flights[h[0]]=h[1]}

          doc.xpath("//pricing/variant").map{|rec| recomendation(rec, flights)}
        end

        def recomendation(rec, flights)
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

          fare = rec.xpath("direction/price/fare")[0].inner_text.to_f
          total = rec.xpath("direction/price/total")[0].inner_text.to_f
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
          dep_iata = fi.xpath("origin").inner_text
          arr_iata = fi.xpath("destination").inner_text
          # Здесь должно быть что-то, что конвертировало бы русское в английское
          dep_iata = convert_to_en(dep_iata)
          arr_iata = convert_to_en(arr_iata)
          f = Flight.new(
            :operating_carrier_iata => fi.xpath("company").inner_text,
            :marketing_carrier_iata => fi.xpath("company").inner_text,
            :departure_iata =>         dep_iata,
            :departure_term =>         fi.xpath("origin").attribute("terminal") && fi.xpath("origin").attribute("terminal").value,
            :arrival_iata =>           arr_iata,
            :arrival_term =>           fi.xpath("destination").attribute("terminal") && fi.xpath("destination").attribute("terminal").value,
            :flight_number =>          fi.xpath("num").inner_text,
            :arrival_date =>           fi.xpath("arrvdate").inner_text.gsub(".", ""),
            :arrival_time =>           to_amadeus_time(fi.xpath("arrvtime").inner_text),
            :departure_date =>         fi.xpath("deptdate").inner_text.gsub(".", ""),
            :departure_time =>         to_amadeus_time(fi.xpath("depttime").inner_text),
            :equipment_type_iata =>    "", # что это?
            :technical_stops => [] #не нашла, есть ли там информация на эту тему. скорее нет
          )
          id = fi.attribute("id") && fi.attribute("id").value
          [id, {:flight=>f, :time=>fi.xpath("flightTime").inner_text}]
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
end
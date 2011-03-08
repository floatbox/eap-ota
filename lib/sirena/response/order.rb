module Sirena
  module Response
    class Order < Sirena::Response::Base
      attr_accessor :number, :flights, :booking_classes, :passengers, :phone, :email, :raw

      def initialize(*)
        super
        puts doc
        @number = xpath("//regnum").first
        if @number
          @number=@number.text
        end

        @passengers = xpath("//passengers/passenger").map{|p|
          Person.new({
            :first_name=>p.xpath("name").text,
            :last_name=>p.xpath("surname").text,
            :passport=>p.xpath("doc").text,
            :sex=>p.xpath("sex").text
          })
        }
        @booking_classes = []
        @flights = xpath("//segments/segment").map{|s|
          @booking_classes << s.xpath("class").text
          Flight.new({
            :flight_number=>           s.xpath("flight").text,
            :operating_carrier_iata => s.xpath("company").text,
            :marketing_carrier_iata => s.xpath("company").text,
            :departure_iata =>         s.xpath("departure/airport").text,
            :arrival_iata =>           s.xpath("arrival/airport").text,
            :arrival_date =>           s.xpath("arrival/date").text.gsub(".", ""),
            :arrival_time =>           to_amadeus_time(s.xpath("arrival/time").text),
            :departure_date =>         s.xpath("departure/date").text.gsub(".", ""),
            :departure_time =>         to_amadeus_time(s.xpath("departure/time").text),
            :equipment_type_iata =>    s.xpath("airplane").text, # иногда кириллица!
            :technical_stops => []
          })
        }
        @phone, @email = xpath("//contacts/contact").map(&:text)
      end
    end
  end
end

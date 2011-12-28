module Sirena
  module Response
    class Order < Sirena::Response::Base
      attr_accessor :number, :flights, :booking_classes, :passengers, :phone, :email, :ticket_hashes

      def parse
        @number = xpath("//regnum").text
        @passengers = xpath("//passengers/passenger").map do |p|
          Person.new({
            :first_name => p.xpath("name").text.split(' ')[0...-1].join(' '),#тк последнее слово - дата рождения
            :last_name => p.xpath("surname").text,
            :passport => p.xpath("doc").text,
            :sex => p.xpath("sex").text,
            :tickets => passenger_tickets(p["id"]),
            :birthdate => Date.parse(p.xpath("birthdate").text)
          })
        end
        @booking_classes = []
        @flights = xpath("//segments/segment").map do |s|
          @booking_classes << s.xpath("class").text

          # иногда не отдается airport. рискну предположить, что это в случае
          # если код аэропорта совпадает с кодом города
          departure_iata = s.xpath("departure/airport").text.presence ||
            s.xpath("departure/city").text
          arrival_iata = s.xpath("arrival/airport").text.presence ||
            s.xpath("arrival/city").text

          Flight.new({
            :flight_number =>          s.xpath("flight").text,
            :operating_carrier_iata => s.xpath("company").text,
            :marketing_carrier_iata => s.xpath("company").text,
            :departure_iata =>         departure_iata,
            :arrival_iata =>           arrival_iata,
            :arrival_date =>           s.xpath("arrival/date").text.gsub(".", ""),
            :arrival_time =>           to_amadeus_time(s.xpath("arrival/time").text),
            :departure_date =>         s.xpath("departure/date").text.gsub(".", ""),
            :departure_time =>         to_amadeus_time(s.xpath("departure/time").text),
            :equipment_type_iata =>    s.xpath("airplane").text, # иногда кириллица!
            :technical_stops => []
          })
        end
        @phone = xpath("//contacts/contact[1]|//contacts/phone[1]").text
        # передаем в сирену наш email, поэтому здесь его ловить бессмысленно
        # @email = xpath("//contacts/email").text
        parse_tickets
      end

      def passenger_tickets(passenger_id)
          xpath("//tickinfo[@pass_id=#{passenger_id}][.='ticket']").map{|tickinfo|
                      tickinfo["ticknum"]
          }.uniq.map do |ticknum|
            t = Ticket.find_or_initialize_by_code_and_number_and_kind(
              (ticknum.match(/([\d\w]+)-?(\d{10}-?\d*)/).to_a)[1],
              (ticknum.match(/([\d\w]+)-?(\d{10}-?\d*)/).to_a)[2],
              'ticket'
            )
            t.status ||= 'ticketed'
            t
          end.delete_if {|t| t.status != 'ticketed'}

      end

      def parse_tickets
        result = {}
        xpath("//tickinfo[.='ticket']").each{|tickinfo|
          number = tickinfo["ticknum"]
          seg_id = tickinfo['seg_id']
          pass_id = tickinfo['pass_id']
          price_element = xpath("//price[@segment-id=#{seg_id}][@passenger-id=#{pass_id}]")
          price_fare = price_element.xpath("fare/value").text.to_f
          price_tax = price_element.xpath("taxes/tax/value").map{|v| v.text.to_f}.sum
          cabin = price_element.at_xpath("fare/code/@base_code").to_s
          flight_element = xpath("//segments/segment[@id=#{seg_id}]")
          departure_iata = flight_element.xpath("departure/airport").text.presence ||
            flight_element.xpath("departure/city").text
          arrival_iata = flight_element.xpath("arrival/airport").text.presence ||
            flight_element.xpath("arrival/city").text
          carrier = flight_element.xpath("company").text
          first_name = xpath("//passenger[@id=#{pass_id}]/name").text.split(' ')[0...-1].join(' ')
          last_name = xpath("//passenger[@id=#{pass_id}]/surname").text
          passport = xpath("//passenger[@id=#{pass_id}]/doc").text

          res = result[number] ||= {:flights => [], :price_fare => 0, :price_tax => 0, :cabins => [], :flights => [], :first_name => first_name, :last_name => last_name, :passport => passport}
          res[:price_fare] += price_fare
          res[:price_tax] += price_tax
          res[:cabins] << cabin
          res[:flights] << "#{departure_iata} - #{arrival_iata} (#{carrier})"
        }
        @ticket_hashes = result.map do |k, v| {
            :source => 'sirena',
            :pnr_number => @number,
            :number => (k.match(/([\d\w]+)-?(\d{10}-?\d*)/).to_a)[2],
            :code => (k.match(/([\d\w]+)-?(\d{10}-?\d*)/).to_a)[1],
            :price_fare => v[:price_fare],
            :price_tax => v[:price_tax],
            :cabins => v[:cabins].uniq.join(' + '),
            :route => v[:flights].join('; '),
            :first_name => v[:first_name],
            :last_name => v[:last_name],
            :passport => v[:passport],
            :status => 'ticketed'
          }
        end

      end

    end
  end
end


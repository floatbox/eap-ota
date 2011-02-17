# encoding: utf-8
module Sirena
  module Request
    class Booking < Sirena::Request::Base
      attr_accessor :passengers, :segments, :phone

      def initialize(order)
        # актуальные коды документов:
        # ПС - паспорт РФ
        # ПСП - загранпаспорт РФ
        # СР - свидетельство о рождении
        # ЗА - загранпаспорт не РФ
        # НП - национальный паспорт (я так понимаю, что это паспорт не РФ)
        @passengers = order.people.collect{|person|
          expire_date = person.document_noexpiration ? nil : person.document_expiration_date.strftime('%d.%m.%y')
          # угадайка. может, имеет смысл добавить в форму?
          doccode = if person.infant_or_child
            "СР"
          elsif !person.nationality || person.nationality.alpha2 != "RU"
            person.document_noexpiration ? "НП" : "ЗА"
          else
            person.document_noexpiration ? "ПС" : "ПСП"
          end
          pass_code = person.infant_or_child == 'i' ? "INFANT" : (person.infant_or_child == 'c' ? "CHILD" : "ААА")
          {
            :family=>person.last_name,
            :name=>person.first_name,
            :document=>person.passport,
            :doccode => doccode,
            :expire_date=>expire_date,
            :code=>pass_code,
            :sex=>(person.sex == 'm' ? "male" : "female"),
            :birthdate=>person.birthday.strftime('%d.%m.%y'),
            :nationality=>person.nationality && person.nationality.alpha2
          }
        }

        @segments = order.recommendation.flights.collect{|flight|
          i ||= -1
          { :departure => flight.departure_iata,
            :arrival=> flight.arrival_iata,
            :company=> flight.operating_carrier_iata,
            :num=>flight.flight_number,
            :date => sirena_date(flight.departure_date),
            :subclass => order.recommendation.booking_classes[i+=1]
          }
        }

        @phone = order.phone
      end

      def fake_passenger(lat=false)
        data = {
          :family=>"ЧАПАЕВ",
          :name=>"ВАСИЛИЙ ИВАНОВИЧ",
          :document=>"1234561234",
          :code=>"ААА",
          :sex=>"male",
          :birthdate=>"28.01.87"
        }
        if lat
          data[:family]="CHAPAEV"
          data[:name]="VASILII IVANOVICH"
        end
        data
      end

    end
  end
end
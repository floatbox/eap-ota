# encoding: utf-8
module Sirena
  module Request
    class Booking < Sirena::Request::Base
      attr_accessor :passengers, :segments, :phone, :email

      def initialize(order, recommendation = nil)
        if recommendation
          fake_init(order, recommendation)
          return
        end
        # актуальные коды документов:
        # ПС - паспорт РФ
        # ПСП - загранпаспорт РФ
        # СР - свидетельство о рождении
        # ЗА - загранпаспорт не РФ
        # НП - национальный паспорт (я так понимаю, что это паспорт не РФ)
        infant_num = 0
        order.people_count[:infants] - order.people_count[:adults]
        @passengers = order.people.collect{|person|
          expire_date = person.document_noexpiration ? nil : person.document_expiration_date.strftime('%d.%m.%y')
          doccode = person.doccode_sirena
          pass_code = case person.infant_or_child
                      when 'i' then
                        infant_num+=1
                        if infant_num <= order.people_count[:adults]
                          "РМГ"
                        else
                          "РВГ"
                        end
                      when 'c' then "РБГ"
                      else "ААА" end
          {
            :family=>person.last_name,
            :name=>person.first_name_sirena,
            :document=>person.passport_sirena,
            :doccode => doccode,
            :expire_date=>expire_date,
            :code=>pass_code,
            :sex=>(person.sex == 'm' ? "male" : "female"),
            :birthdate=>person.birthday.strftime('%d.%m.%y'),
            :nationality=>person.nationality && person.nationality.alpha2
          }
        }

        init_segments(order.recommendation)

        @phone = order.phone
        @email = order.email
      end

      def fake_init(form, recommendation)
        @passengers = fake_adults(form.people_count[:adults])+
                      fake_children(form.people_count[:children])+
                      fake_infants(form.people_count[:infants], form.people_count[:adults])
        init_segments(recommendation)
        @phone = "+7 495 660-35-20"
        @email = "hello@eviterra.com"
      end

      def init_segments(recommendation)
        @segments = recommendation.flights.collect do |flight|
          { :departure => flight.departure_iata,
            :arrival => flight.arrival_iata,
            :company => flight.operating_carrier_iata,
            :num => flight.flight_number,
            :date => sirena_date(flight.departure_date),
            :subclass => recommendation.booking_class_for_flight(flight)
          }
        end
      end

      def fake_adults(count)
        [{
          :family=>"CHAPAEV",
          :name=>"VASILIY IVANOVICH",
          :document=>"1234561234",
          :doccode=>"ПС",
          :code=>"ААА",
          :sex=>"male",
          :birthdate=>"28.01." + ('%02d' % ((Date.today.year-35)%100))
        },
        {
          :family=>"CHAPAEV",
          :name=>"IVAN STEPANOVICH",
          :document=>"2233445566",
          :doccode=>"ПС",
          :code=>"ААА",
          :sex=>"male",
          :birthdate=>"13.05." + ('%02d' % ((Date.today.year-35)%100))
        },
       {
          :family=>"CHAPAEV",
          :name=>"SERGEI IVANOVICH",
          :document=>"1234561234",
          :doccode=>"ПС",
          :code=>"ААА",
          :sex=>"male",
          :birthdate=>"28.01." + ('%02d' % ((Date.today.year-35)%100))
        },
        {
          :family=>"CHAPAEV",
          :name=>"YURI IVANOVICH",
          :document=>"1234561234",
          :doccode=>"ПС",
          :code=>"ААА",
          :sex=>"male",
          :birthdate=>"28.01." + ('%02d' % ((Date.today.year-35)%100))
        },
        {
          :family=>"CHAPAEV",
          :name=>"NICKOLAY IVANOVICH",
          :document=>"1234561234",
          :doccode=>"ПС",
          :code=>"ААА",
          :sex=>"male",
          :birthdate=>"28.01." + ('%02d' % ((Date.today.year-35)%100))
        },
        {
          :family=>"CHAPAEV",
          :name=>"MIKHAIL IVANOVICH",
          :document=>"1234561234",
          :doccode=>"ПС",
          :code=>"ААА",
          :sex=>"male",
          :birthdate=>"28.01." + ('%02d' % ((Date.today.year-35)%100))
        },
        {
          :family=>"CHAPAEVA",
          :name=>"SOPHIA IVANOVNA",
          :document=>"1234561234",
          :doccode=>"ПС",
          :code=>"ААА",
          :sex=>"female",
          :birthdate=>"28.01." + ('%02d' % ((Date.today.year-35)%100))
        },
        {
          :family=>"CHAPAEVA",
          :name=>"ANNA IOANNA",
          :document=>"1234561234",
          :doccode=>"ПС",
          :code=>"ААА",
          :sex=>"female",
          :birthdate=>"28.01." + ('%02d' % ((Date.today.year-35)%100))
        }][0...count]
      end

      def fake_children(count)
        [{
          :family=>"ISAEV",
          :name=>"PETR SEMENOVICH",
          :document=>"123456",
          :doccode=>"СР",
          :code=>"РБГ",
          :sex=>"male",
          :birthdate=>"15.04." + ('%02d' % ((Date.today.year-5)%100))
        },
        {
          :family=>"ISAEV",
          :name=>"EVGENII SEMENOVICH",
          :document=>"123456",
          :doccode=>"СР",
          :code=>"РБГ",
          :sex=>"male",
          :birthdate=>"15.04." + ('%02d' % ((Date.today.year-5)%100))
        },
        {
          :family=>"ISAEV",
          :name=>"GIRIGORY SEMENOVICH",
          :document=>"123456",
          :doccode=>"СР",
          :code=>"РБГ",
          :sex=>"male",
          :birthdate=>"15.04." + ('%02d' % ((Date.today.year-5)%100))
        },
        {
          :family=>"ISAEV",
          :name=>"EVLAMPIY SEMENOVICH",
          :document=>"123456",
          :doccode=>"СР",
          :code=>"РБГ",
          :sex=>"male",
          :birthdate=>"15.04." + ('%02d' % ((Date.today.year-5)%100))
        },
        {
          :family=>"ISAEV",
          :name=>"VLADIMIR SEMENOVICH",
          :document=>"123456",
          :doccode=>"СР",
          :code=>"РБГ",
          :sex=>"male",
          :birthdate=>"15.04." + ('%02d' % ((Date.today.year-5)%100))
        },
        {
          :family=>"ISAEV",
          :name=>"SEMEN SEMENOVICH",
          :document=>"123456",
          :doccode=>"СР",
          :code=>"РБГ",
          :sex=>"male",
          :birthdate=>"15.04." + ('%02d' % ((Date.today.year-5)%100))
        },
        {
          :family=>"ISAEV",
          :name=>"DMITRY SEMENOVICH",
          :document=>"123456",
          :doccode=>"СР",
          :code=>"РБГ",
          :sex=>"male",
          :birthdate=>"15.04." + ('%02d' % ((Date.today.year-5)%100))
        }][0...count]
      end

      def fake_infants(count, adults_count)
        infs = [{
          :family=>"POPOVA",
          :name=>"MARIA ANDREEVNA",
          :document=>"125678",
          :doccode=>"СР",
          :code=>"РМГ",
          :sex=>"female",
          :birthdate=>"04.09." + ('%02d' % ((Date.today.year-1)%100))
        },
        {
          :family=>"POPOVA",
          :name=>"ELENA ANDREEVNA",
          :document=>"125678",
          :doccode=>"СР",
          :code=>"РМГ",
          :sex=>"female",
          :birthdate=>"04.09." + ('%02d' % ((Date.today.year-1)%100))
        },
        {
          :family=>"POPOVA",
          :name=>"IRINA ANDREEVNA",
          :document=>"125678",
          :doccode=>"СР",
          :code=>"РМГ",
          :sex=>"female",
          :birthdate=>"04.09." + ('%02d' % ((Date.today.year-1)%100))
        },
        {
          :family=>"POPOVA",
          :name=>"LUKERIA ANDREEVNA",
          :document=>"125678",
          :doccode=>"СР",
          :code=>"РМГ",
          :sex=>"female",
          :birthdate=>"04.09." + ('%02d' % ((Date.today.year-1)%100))
        }][0...count]
        infs[adults_count...count].each{|inf| inf[:code] = "РВГ"} if adults_count < count
        infs
      end
    end
  end
end


require 'spec_helper'

describe BookingController do

  describe '#api_manual_booking' do

    let :request_params do
      {:request => {
        :src => 'LED',                                  #IATA города или аэропорта вылета
        :dst => 'MOW',                                  #IATA города или аэропорта прилета
        :dir => '2011-09-28',                           #Дата прямого вылета в формате
        :cls => 'P',                                    #Cabin (E – эконом, B – бизнес, F – первый, P – премиум, A – любой)
        :adt =>  1                                      #Кол-во взрослых
      },
      :response => {
        :va  => 'SU',                                   #Validating airline (авиакомпания, на бланке которой выписывается билет)
        :dir => [{                                      #Cегменты прямого перелета
          :bcl => 'M',                                  #Booking_class
          :cls => 'P',                                   #Cabin
          :oa  => 'SU',                                 #Перевозчик, владелец самолета (IATA код Operating Airline)
          :n   => '840',                                #Номер рейса
          :ma  => 'SU',                                 #Авиакомпания, которую пишут в номере рейса (IATA код Marketing Airline)
          :eq  => '320',                                #IATA код типа самолета
          :dur => '75',                                 #Длительность перелета в сегменте (мин)
          :dep =>{                                      #Данные вылета
            :p  => 'LED',                               #IATA код аэропорта
            :dt => '2011-09-28 11:55',                  #Дата и время в формате ГГГГ-ММ-ДД ЧЧ:ММ:СС
            :t  => '1'                                  #Терминал, если есть, иначе пустая строка
            },
          :arr =>{                                      #Данные приземления (аналогичны dep)
            :p => 'SVO',
            :d => '2011-09-28 13:10',
            :t => 'D'
            }
          }],
        :ret => [],                                     #Дата обратного вылета
        :c   => 2151,                                   #Цена (рубли)
        :c1  => 2151                                    #Цена за одного взрослого пассажира
      }}
    end

    it 'creates appropriate pricer_form' do

      pricer_form = mock('PricerForm')
      PricerForm.should_receive(:simple).with(
        :from => 'LED',
        :to => 'MOW',
        :date1 => '280912',
        :adults => 1,
        :cabin => 'C' ).and_return(pricer_form)
      get :api_manual_booking, request_params

    end

    it 'creates appropriate recommendation' do

      flights = mock('Flight')
      segments = mock('Segment')
      variant = mock('Variant')
      recommendation = mock('Recommendation')

      get :api_manual_booking
      Flight.should_receive(:new).with(hash_including(
        :operating_carrier_iata => 'SU',
        :marketing_carrier_iata => 'SU',
        :flight_number => '840',
        :departure_iata => 'LED',
        :arrival_iata => 'MOW',
        :departure_date => '280912')).and_return(flights)
      Segment.should_receive(:new).with(:flights => [flights]).and_return(segments)
      Variant.should_receive(:new).with(:segments => [segments]).and_return(variant)
      Recommendation.should_receive(:new).with(hash_including(
        :source => 'amadeus',
        :validating_carrier_iata => 'SU',
        :booking_classes => ['M'],
        :cabins => ['C'],
        :variants => [variant])).and_return(recommendation)
    end


    it 'redirects on booking of deliberate flight page' do
      get :api_manual_booking
      response.should redirect_to(:action => 'preliminary_booking', :controller => 'booking')
    end

  end
end


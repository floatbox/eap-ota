require 'spec_helper'

describe BookingController do

  describe '#api_rambler_booking' do

    let :request_params do
      { :va  => 'SU',                                   #Validating airline (авиакомпания, на бланке которой выписывается билет)
        :dir => { 0=> {                                      #Cегменты прямого перелета
          :bcl => 'M',                                  #Booking_class
          :cls => 'P',                                  #Cabin
          :oa  => 'SU',                                 #Перевозчик, владелец самолета (IATA код Operating Airline)
          :n   => '840',                                #Номер рейса
          :ma  => 'SU',                                 #Авиакомпания, которую пишут в номере рейса (IATA код Marketing Airline)
          :eq  => '320',                                #IATA код типа самолета
          :dur => '75',                                 #Длительность перелета в сегменте (мин)
          :dep =>{                                      #Данные вылета
            :p  => 'LED',                               #IATA код аэропорта
            :dt => '280911',                            #Дата и время в формате ГГГГ-ММ-ДД ЧЧ:ММ:СС
            :t  => '1'                                  #Терминал, если есть, иначе пустая строка
            },
          :arr =>{                                      #Данные приземления (аналогичны dep)
            :p => 'SVO',
            :d => '280911',
            :t => 'D'
            }
          }},
        :ret => {},                                     #Дата обратного вылета
        :c   => 2151,                                   #Цена (рубли)
        :c1  => 2151                                    #Цена за одного взрослого пассажира
      }
    end

    it 'creates appropriate pricer_form' do
      pricer_form = mock('PricerForm')
      recommendation = mock('Recommendation')
      recommendation.stub(:deserialize)

      PricerForm.should_receive(:simple).with(hash_including(
        :from => 'LED',
        :to => 'MOW',
        :date1 => '280911',
        :adults => 1,
        :cabin => 'C')).and_return(pricer_form)
      pricer_form.stub(:valid?).and_return('true')
      pricer_form.stub(:save_to_cache).and_return('true')
      pricer_form.stub(:query_key).and_return('7dd6jv')
      get :api_rambler_booking, request_params
    end

    it 'creates appropriate recommendation' do
      flights = mock('Flight')
      segments = [mock('Segment')]
      recommendation = mock('Recommendation')
      segments.stub(:flights).and_return(flights)
      flights.stub_chain(:departure, :city, :iata).and_return('LED')
      flights.stub_chain(:arrival, :city, :iata).and_return('SVO')
      flights.stub(:departure_date).and_return('280911')
      recommendation.stub_chain(:cabins, :first).and_return('P')


      Flight.should_receive(:new).with(hash_including(
        :operating_carrier_iata => 'SU',
        :marketing_carrier_iata => 'SU',
        :flight_number => '840',
        :departure_iata => 'LED',
        :arrival_iata => 'SVO',
        :departure_date => '280911')).and_return(flights)
      Recommendation.should_receive(:new).with(hash_including(
        :source => 'amadeus',
        :validating_carrier_iata => 'SU',
        :booking_classes => ['M'],
        :cabins => ['C']
        )).and_return(recommendation)
      recommendation.should_receive(:serialize).and_return("amadeus.SU.N.P..SU840LEDMOW280911" )
      get :api_rambler_booking, request_params
    end
  end
end
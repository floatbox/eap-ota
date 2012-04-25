require 'spec_helper'

describe BookingController do
  describe '#api_rambler_booking' do

    let :request_params do
      { :va  => 'SU',                                   #Validating airline (авиакомпания, на бланке которой выписывается билет)
        :dir => { '0' => {                                      #Cегменты прямого перелета
          :bcl => 'M',                                  #Booking_class
          :cls => 'B',                                  #Cabin
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
        :cabin => 'C',
        :partner => 'rambler')).and_return(pricer_form)
      pricer_form.stub(:valid?).and_return('true')
      pricer_form.stub(:save_to_cache).and_return('true')
      pricer_form.stub(:query_key)
      pricer_form.stub(:partner).and_return('rambler')
      get :api_rambler_booking, request_params.merge(:format => 'xml')
    end

    it 'creates appropriate recommendation' do
      flights = mock('Flight')
      segments = [mock('Segment')]
      recommendation = mock('Recommendation')
      segments.stub(:flights).and_return(flights)
      flights.stub_chain(:departure, :city, :iata).and_return('LED')
      flights.stub_chain(:arrival, :city, :iata).and_return('SVO')
      flights.stub(:departure_date).and_return('280911')
      recommendation.stub_chain(:cabins, :first).and_return('C')


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
      recommendation.should_receive(:serialize).and_return("amadeus.SU.N.C..SU840LEDMOW280911" )
      get :api_rambler_booking, request_params.merge(:format => 'xml')
    end
  end

  context 'how do we deal with partners and markers' do
    let :partner_and_marker_present do
      {
        :query_key => 'f45g6h',
        :partner => 'yandex',
        :marker => 'ffdghg'
      }
    end
    let :partner_present do
      {
        :query_key => 'f45g6h',
        :partner => 'momondo',
      }
    end
    let :marker_present do
      {
        :query_key => 'f45g6h',
        :marker => 'rebkloi'
      }
    end

    describe '#api_booking' do
      it 'saves both partner and marker if they present' do
        Recommendation.stub(:deserialize)
        strategy = mock('strategy')
        Strategy.stub(:select).and_return(strategy)
        strategy.stub(:check_price_and_availability).and_return(true)
        pricer = mock('pricer')
        PricerForm.stub(:load_from_cache).and_return(pricer)
        pricer.stub(:partner)
        pricer.stub(:real_people_count)
        pricer.stub(:human_lite)
        pricer.stub(:query_key)
        pricer.stub(:segments)
        order = mock('order')
        order.stub(:save_to_cache)
        order.stub(:number)
        Partner.create(:token => 'yandex', :cookies_expiry_time => 10, :enabled => true,  :password => 1)

        get :api_booking, partner_and_marker_present
        response.cookies['partner'].should == 'yandex'
        response.cookies['marker'].should == 'ffdghg'
      end

      it 'saves partner if it is present' do
        Recommendation.stub(:deserialize)
        strategy = mock('strategy')
        Strategy.stub(:select).and_return(strategy)
        strategy.stub(:check_price_and_availability).and_return(true)
        pricer = mock('pricer')
        PricerForm.stub(:load_from_cache).and_return(pricer)
        pricer.stub(:partner)
        pricer.stub(:real_people_count)
        pricer.stub(:human_lite)
        pricer.stub(:query_key)
        pricer.stub(:segments)
        order = mock('order')
        order.stub(:save_to_cache)
        order.stub(:number)
        Partner.create(:token => 'momondo', :cookies_expiry_time => 10, :enabled => true,  :password => 1)

        get :api_booking, partner_present
        response.cookies['partner'].should == 'momondo'
        response.cookies['marker'].should == nil
      end

      it "doesn't touch cookie if there's no partner"  do
        Recommendation.stub(:deserialize)
        strategy = mock('strategy')
        Strategy.stub(:select).and_return(strategy)
        strategy.stub(:check_price_and_availability).and_return(true)
        pricer = mock('pricer')
        PricerForm.stub(:load_from_cache).and_return(pricer)
        pricer.stub(:partner)
        pricer.stub(:real_people_count)
        pricer.stub(:human_lite)
        pricer.stub(:query_key)
        pricer.stub(:segments)
        order = mock('order')
        order.stub(:save_to_cache)
        order.stub(:number)

        get :api_booking, marker_present
        response.cookies['partner'].should == nil
        response.cookies['marker'].should == nil
      end
    end

    describe '#api_redirect' do
      it 'saves both partner and marker if they are present' do
        pricer = mock('pricer')
        PricerForm.stub(:simple).and_return(pricer)
        pricer.stub(:valid?)
        Partner.create(:token => 'yandex', :cookies_expiry_time => 10, :enabled => true,  :password => 1)

        get :api_redirect, partner_and_marker_present
        response.cookies['partner'].should == 'yandex'
        response.cookies['marker'].should == 'ffdghg'
      end

      it 'saves partner if it is present' do
        pricer = mock('pricer')
        PricerForm.stub(:simple).and_return(pricer)
        pricer.stub(:valid?)
        Partner.create(:token => 'momondo', :cookies_expiry_time => 10, :enabled => true,  :password => 1)

        get :api_redirect, partner_present
        response.cookies['partner'].should == 'momondo'
        response.cookies['marker'].should == nil
      end

      it "doesn't touch cookie if there's no partner"  do
        pricer = mock('pricer')
        PricerForm.stub(:simple).and_return(pricer)
        pricer.stub(:valid?)
        pricer.stub(:partner)
        Partner.create(:token => 'momondo', :cookies_expiry_time => 10, :enabled => true,  :password => 1)

        get :api_redirect, marker_present
        response.cookies['partner'].should == nil
        response.cookies['marker'].should == nil
      end
    end
  end
end

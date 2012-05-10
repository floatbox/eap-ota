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

    describe '#preliminary_booking' do

      before do
        # stubbing preliminary_booking internal methods
        Recommendation.stub(:deserialize)
        strategy = mock('Strategy', check_price_and_availability: nil).as_null_object
        Strategy.stub(:select).and_return(strategy)
        PricerForm.stub(:load_from_cache).and_return(mock('PricerForm'))
      end

      it 'saves both partner and marker if they present' do
        Partner.create(:token => 'yandex', :cookies_expiry_time => 10, :enabled => true,  :password => 1)

        get :preliminary_booking, partner_and_marker_present
        response.cookies['partner'].should == 'yandex'
        response.cookies['marker'].should == 'ffdghg'
      end

      it 'saves partner if it is present' do
        Partner.create(:token => 'momondo', :cookies_expiry_time => 10, :enabled => true,  :password => 1)

        get :preliminary_booking, partner_present
        response.cookies['partner'].should == 'momondo'
        response.cookies['marker'].should == nil
      end

      it "doesn't touch cookie if there's no partner"  do
        Partner.stub(:find_by_token)

        get :preliminary_booking, marker_present
        response.cookies['partner'].should == nil
        response.cookies['marker'].should == nil
      end
    end

    describe '#api_redirect' do
      it 'saves partner if it is present' do
        PricerForm.stub(:simple).and_return(mock('pricer').as_null_object)
        Partner.create(:token => 'momondo', :cookies_expiry_time => 10, :enabled => true,  :password => 1)

        get :api_redirect, partner_present
        response.cookies['partner'].should == 'momondo'
        response.cookies['marker'].should == nil
      end

      # зачем этот тест?
      it "doesn't touch cookie if there's no partner"  do
        PricerForm.stub(:simple).and_return(mock('pricer').as_null_object)
        Partner.stub(:find_by_token)

        get :api_redirect, marker_present
        response.cookies['partner'].should == nil
        response.cookies['marker'].should == nil
      end
    end
  end
  describe '#log_referrer' do
    it "doesn't log if source and target hosts are the same" do
      PricerForm.stub(:simple).and_return(mock('pricer').as_null_object)
      logger = mock('logger')
      controller.stub(:logger).and_return(logger)

      request.stub(:referrer).and_return("http://eviterra.com")
      request.stub(:host).and_return("eviterra.com")
      logger.should_not_receive(:info)

      get :api_redirect
    end

    it "logs if source and target hosts are the same" do
      PricerForm.stub(:simple).and_return(mock('pricer').as_null_object)
      logger = mock('logger')
      controller.stub(:logger).and_return(logger)

      request.stub(:referrer).and_return("http://yandex.ru/blah")
      request.stub(:host).and_return("eviterra.com")
      logger.should_receive(:info)

      get :api_redirect
    end
  end
end

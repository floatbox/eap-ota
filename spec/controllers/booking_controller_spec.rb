require 'spec_helper'

describe BookingController do
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
    let(:pricer){AviaSearch.simple(:from => 'MOW', :to => 'PAR', :date1 => DateTime.tomorrow.strftime("%d.%m.%Y"))}

    describe '#create' do

      before do
        # stubbing preliminary_booking internal methods
        recommendation = Recommendation.new(:booking_classes => ['Y'])
        recommendation.stub(:find_commission!)
        recommendation.stub(:allowed_booking?).and_return(true)
        Recommendation.stub(:deserialize).and_return(recommendation)
        strategy = mock('Strategy', check_price_and_availability: nil).as_null_object
        Strategy.stub(:select).and_return(strategy)
        AviaSearch.stub(:from_code).and_return(pricer)
      end

      it 'saves both partner and marker if they present' do
        Partner.create(:token => 'yandex', :cookies_expiry_time => 10, :enabled => true,  :password => 1)

        post :create, partner_and_marker_present
        response.cookies['partner'].should == 'yandex'
        response.cookies['marker'].should == 'ffdghg'
      end

      it 'saves partner if it is present' do
        Partner.create(:token => 'momondo', :cookies_expiry_time => 10, :enabled => true,  :password => 1)

        post :create, partner_present
        response.cookies['partner'].should == 'momondo'
        response.cookies['marker'].should == nil
      end

      it "doesn't touch cookie if there's no partner"  do
        Partner.stub(:find_by_token)

        post :create, marker_present
        response.cookies['partner'].should == nil
        response.cookies['marker'].should == nil
      end
    end

    describe '#api_redirect' do
      it 'saves partner if it is present' do
        AviaSearch.stub(:simple).and_return(mock('pricer').as_null_object)
        Partner.create(:token => 'momondo', :cookies_expiry_time => 10, :enabled => true,  :password => 1)

        get :api_redirect, partner_present
        response.cookies['partner'].should == 'momondo'
        response.cookies['marker'].should == nil
      end

      # зачем этот тест?
      it "doesn't touch cookie if there's no partner"  do
        AviaSearch.stub(:simple).and_return(mock('pricer').as_null_object)
        Partner.stub(:find_by_token)

        get :api_redirect, marker_present
        response.cookies['partner'].should == nil
        response.cookies['marker'].should == nil
      end
    end
  end
  describe '#log_referrer' do
    it "doesn't log if source and target hosts are the same" do
      AviaSearch.stub(:simple).and_return(mock('pricer').as_null_object)
      logger = mock('logger')
      controller.stub(:logger).and_return(logger)

      request.stub(:referrer).and_return("http://eviterra.com")
      request.stub(:host).and_return("eviterra.com")
      logger.should_not_receive(:info).with('Referrer:')

      get :api_redirect
    end

    it "logs if source and target hosts are the same" do
      AviaSearch.stub(:simple).and_return(mock('pricer').as_null_object)
      logger = mock('logger')
      controller.stub(:logger).and_return(logger)

      request.stub(:referrer).and_return("http://yandex.ru/blah")
      request.stub(:host).and_return("eviterra.com")
      logger.should_receive(:info).at_least(1)

      get :api_redirect
    end
  end
end

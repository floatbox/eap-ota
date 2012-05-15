# encoding: utf-8
require 'spec_helper'
class PartnerTrackingController < BookingController
  def index
    track_partner params[:partner], params[:marker]
    render :text => ""
  end
end

describe PartnerTrackingController do

  describe '#track_partner' do
    let(:get_params) { {:partner => 'wobwobwirrr'} }
    subject { PartnerTrackingController.new }

    it "doesn't create cookie if there's no such partner" do
      Partner.stub(:find_by_token)
      get :index, get_params
      response.cookies['partner'].should == nil
    end

    context "expiry time" do
      let(:stub_cookie_jar) { HashWithIndifferentAccess.new }
      before { controller.stub( cookies: stub_cookie_jar ) }

      it "creates cookies with correct exp time if such was specified in its partner" do
        Partner.create(:token => 'wobwobwirrr', :enabled => true, :password => 1, :cookies_expiry_time => 10)

        get :index, get_params

        expiring_cookie = stub_cookie_jar['partner']
        expiring_cookie[:expires].should be_within(1.minute).of(10.days.from_now)
      end


      it "creates default cookie even if exp_time is nil" do
        Partner.create(:token => 'wobwobwirrr', :enabled => true, :password => 1, :cookies_expiry_time => nil)

        get :index, get_params

        expiring_cookie = stub_cookie_jar['partner']
        expiring_cookie[:expires].should be_within(1.minute).of(Partner.default_expiry_time.days.from_now)
      end

    end
  end
end

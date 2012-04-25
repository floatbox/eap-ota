# encoding: utf-8
require 'spec_helper'
class PartnerTrackingController < BookingController
  def track_partner
    super params[:partner]
    render :text => ""
  end
end

describe PartnerTrackingController do

  describe '#track_partner' do
    let(:hash){{:partner => 'wobwobwirrr'}}

    subject{PartnerTrackingController.new}

    it "creates cookies with correct exp time if such was specified in its partner" do
      Partner.create(:token => 'wobwobwirrr', :enabled => true, :password => 1, :cookies_expiry_time => 10)
      stub_cookie_jar = HashWithIndifferentAccess.new
      controller.stub(:cookies) { stub_cookie_jar }

      get :track_partner, hash

      expiring_cookie = stub_cookie_jar['partner']
      expiring_cookie[:expires].should be_between 9.days.from_now, 11.days.from_now
    end

    it "doesn't create cookie if there's no such partner" do
      Partner.stub(:find_by_token).and_return(nil)
      get :track_partner, hash
      response.cookies['partner'].should == nil
    end

    it "doesn't create cookie if exp time is nil" do
      Partner.create(:token => 'wobwobwirrr', :enabled => true, :password => 1, :cookies_expiry_time => nil)
      get :track_partner, hash
      response.cookies['partner'].should == nil
    end
  end
end
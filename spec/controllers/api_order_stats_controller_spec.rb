require 'spec_helper'

describe ApiOrderStatsController do
  describe "GET 'index'" do
    let :date_params do {
      :date_start => '2011/12/01',
      :date_end => '2011/12/01'
      }
    end

    it "should authorize with correct identifiers" do
      partner = mock('Partner')
      Partner.stub(:find_by_token).with('rambler').and_return(partner)
      partner.stub(:password).and_return('33')
      request.env["HTTP_AUTHORIZATION"] = "Basic " + Base64::encode64('rambler:33')
      get :index, date_params
      response.should be_success
    end

    it "should not authorize with wrong password" do
      partner = mock('Partner')
      Partner.stub(:find_by_token).with('rambler').and_return(partner)
      partner.stub(:password).and_return('33')
      request.env["HTTP_AUTHORIZATION"] = "Basic " + Base64::encode64('rambler:556')
      get :index, date_params
      response.should_not be_success
    end

    it "should not authorize with wrong username" do
      Partner.stub(:find_by_token).with('wakawakawa').and_return(nil)
      request.env["HTTP_AUTHORIZATION"] = "Basic " + Base64::encode64('wakawakawa:33')
      get :index, date_params
      response.should_not be_success
    end
  end
end

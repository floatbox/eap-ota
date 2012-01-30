require 'spec_helper'

describe ApiOrderStatsController do
  describe "GET 'index'" do
    let :date_params do {
      :date_start => '01.12.2011',
      :date_end => '01.12.2011'
      }
    end

    it "should authorize with correct identifiers" do
      Conf.api.stub(:passwords).and_return({'rambler'=>'33'})
 	    request.env["HTTP_AUTHORIZATION"] = "Basic " + Base64::encode64('rambler:33')
      get :index, date_params
      response.should be_success
    end

    it "should not authorize with wrong password" do
      Conf.api.stub(:passwords).and_return({'rambler'=>'33'})
 	    request.env["HTTP_AUTHORIZATION"] = "Basic " + Base64::encode64('rambler:556')
      get :index, date_params
      response.should_not be_success
    end

    it "should not authorize with wrong username" do
      Conf.api.stub(:passwords).and_return({'rambler'=>'33'})
 	    request.env["HTTP_AUTHORIZATION"] = "Basic " + Base64::encode64('wakawakawa:33')
      get :index, date_params
      response.should_not be_success
    end
  end
end

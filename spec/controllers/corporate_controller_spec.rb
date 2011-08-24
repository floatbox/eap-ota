require 'spec_helper'

describe CorporateController do

  describe "#start" do

    it "sets session[:corporate_mode] to true" do
      post :start
      controller.session[:corporate_mode].should be_true
    end

    it "redirects to /" do
      post :start
      response.should redirect_to(:action => 'index', :controller => 'home')
    end

  end

  describe "#stop" do

    it "sets session[:corporate_mode] to nil" do
      get :stop
      controller.session[:corporate_mode].should_not be_true
    end

    it "redirects to /" do
      get :stop
      response.should redirect_to(:action => 'index', :controller => 'home')
    end

  end
end

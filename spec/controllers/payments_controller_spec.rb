require 'spec_helper'

describe PaymentsController do

 describe "#update" do

    it "shows 404 error when offline_booking set false" do
      debugger
      post :update, :code => "c47b4l"
      record = mock_model(Order, :code=>"c47b4l", :offline_booking => false)
      Order.stub(:find).and_return(record)
      response.should redirect_to(:action => 'index', :controller => 'home')
    end


    it "shows whole error page if last_pay_time has expired" do
      post :update, :code => "c47b4l"
      record = mock_model(Order, :code=>"c47b4l", :last_pay_time => Date.yesterday)
      Order.stub(:find).and_return(record)
      response.should render_template("expired_pay_time")#проверять на статус, док-я - rails rspec matchers controllers
    end

  end

  describe "#edit" do

    it "shows 404 error when offline_booking set false" do
      get :edit, :code => "c47b4l"
      record = mock_model(Order, :code=>"c47b4l", :offline_booking => false)
      Order.stub(:find).and_return(record)
      response.should redirect_to(:action => 'index', :controller => 'home')
    end

    it "shows whole error page if last_pay_time has expired" do
      get :edit, :code => "c47b4l"
      record = mock_model(Order,:code=>"c47b4l", :last_pay_time => Date.yesterday)
      Order.stub(:find).and_return(record)
      response.should render_template("expired_pay_time")
    end

  end
end


require 'spec_helper'

describe PaymentsController do

 describe '#update' do

    it 'shows error page with 404 status when offline_booking set false' do

      record = mock_model(Order, :code => '47b4l', :offline_booking => false, :last_pay_time => Date.tomorrow, :payment_status => '')
      Order.stub(:find_by_code!).and_return(record)
      post :update, :code=> '47b4l'
      response.should render_template('expired_pay_time')
    end


    it 'shows error page with 404 status if last_pay_time has expired' do

      record = mock_model(Order, :code=> '47b4l', :last_pay_time => Date.yesterday, :offline_booking => true, :payment_status => '')
      Order.stub(:find_by_code!).and_return(record)
      post :update, :code => '47b4l'
      response.should render_template('expired_pay_time')
    end

  end

  describe '#edit' do

    it 'shows error page with 404 status when offline_booking set false' do

      record = mock_model(Order, :code => '47b4l', :offline_booking => false, :last_pay_time => Date.tomorrow, :payment_status => '')
      Order.stub(:find_by_code!).and_return(record)
      get :edit, :code => '47b4l'
      response.should render_template('expired_pay_time')
    end

    it 'shows error page with 404 status if last_pay_time has expired' do

      record = mock_model(Order, :code=> '47b4l', :last_pay_time => Date.yesterday, :offline_booking => true, :payment_status => '')
      Order.stub(:find_by_code!).and_return(record)
      get :edit, :code => '47b4l'
      response.should render_template('expired_pay_time')
    end

  end
end


# encoding: utf-8
require 'spec_helper'

describe PaymentsController do

 describe '#update' do

    it 'proceeds when last_pay_time  is ok' do
      order = mock_model(Order, :code => '47b4l', :last_pay_time => 1.day.from_now, :payment_status => '')
      Order.stub(:find_by_code).and_return(order)

      card = mock_model(CreditCard)
      card.stub(:valid?).and_return(false)
      CreditCard.stub(:new).and_return(card)

      post :update, :code=> '47b4l'

      response.status.should == 200
    end

    # FIXME воткнет ведь целую страницу вместо parital?
    it 'shows error page with 404 status when  last_pay_time is not set' do

      order = mock_model(Order, :code => '47b4l', :payment_status => '')
      Order.stub(:find_by_code).and_return(order)
      post :update, :code=> '47b4l'

      response.status.should == 404
      response.should render_template('expired_pay_time')
    end


    it 'shows error page with 404 status if last_pay_time has expired' do

      order = mock_model(Order, :code=> '47b4l', :last_pay_time => 1.day.ago, :payment_status => '')
      Order.stub(:find_by_code).and_return(order)
      post :update, :code => '47b4l'

      response.status.should == 404
      response.should render_template('expired_pay_time')
    end

    pending "shows success page for already processed order (double submit?)"

  end

  describe '#edit' do

    it 'shows error page with 404 status when order with code is not present' do
      Order.stub(:find_by_code).and_return(nil)
      get :edit, :code => 'foobar'

      response.status.should == 404
      response.should render_template('expired_pay_time')
    end

    it 'shows error page with 404 status when code is empty' do
      get :edit, :code => ' '

      response.status.should == 404
      response.should render_template('expired_pay_time')
    end

    it 'shows error page with 404 status when last_pay_time is not set' do

      order = mock_model(Order, :code => '47b4l', :payment_status => '')
      Order.stub(:find_by_code).and_return(order)
      get :edit, :code => '47b4l'

      response.status.should == 404
      response.should render_template('expired_pay_time')
    end

    it 'shows error page with 404 status if last_pay_time has expired' do

      order = mock_model(Order, :code=> '47b4l', :last_pay_time => 1.day.ago, :payment_status => '')
      Order.stub(:find_by_code).and_return(order)
      get :edit, :code => '47b4l'

      response.status.should == 404
      response.should render_template('expired_pay_time')
    end

    pending "shows 'Платеж уже обработан' if payment's already processed"

  end
end


class BookingController < ApplicationController
  
  def index
    #@pnr_form = PNRForm.new(:flight_codes => params[:flight_codes].split('_'))
    require 'variant'
    require 'segment'
    require 'flight'
    @variant = Marshal.load(File.read(Rails.root + 'db/variant.marshal'))
    @people = [1,2, 3]
    @card = Billing::CreditCard.new(valid_card)
  end

  # FIXME temporary bullshit
  def form
    @card = Billing::CreditCard.new(valid_card)
  end

  def pay
    @card = Billing::CreditCard.new(params[:card])

    @order_id = params[:order_id]
    @amount = params[:amount]

    if @card.valid?
      result = Payture.new.pay(@amount, @card, :order_id => @order_id)
      if result["Success"] == "True"
        @message = "Success"
      else
        @message = result["ErrCode"]
      end
      render :form
    else
      render :form
    end
  end

  def valid_card
    {:number => '4111111111111112', :verification_value => '123', :month => 10, :year => 2010, :first_name => 'doesnt', :last_name => 'matter'}
  end
  helper_method :valid_card

end

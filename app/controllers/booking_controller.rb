class BookingController < ApplicationController
  
  def index
    #@pnr_form = PNRForm.new(:flight_codes => params[:flight_codes].split('_'))
    require 'variant'
    require 'segment'
    require 'flight'
    @variant = Marshal.load(File.read(Rails.root + 'db/variant.marshal'))
  end

  def form
    @card = Billing::CreditCard.new(valid_card)
  end

  def pay
    @card = Billing::CreditCard.new(params[:card])
    if @card.valid?
      render :text => 'card is valid'
    else
      render :form
    end
  end

  def valid_card
    {:number => '4111111111111112', :verification_value => '123', :month => 10, :year => 2010, :first_name => 'doesnt', :last_name => 'matter'}
  end
  helper_method :valid_card

end

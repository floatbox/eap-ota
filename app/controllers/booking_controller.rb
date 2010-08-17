class BookingController < ApplicationController
  
  def index
    @pnr_form = PNRForm.new(:flight_codes => params[:flight_codes].split('_'))
  end
end

class BookingController < ApplicationController
  
  def index
    #@pnr_form = PNRForm.new(:flight_codes => params[:flight_codes].split('_'))
    require 'variant'
    require 'segment'
    require 'flight'
    @variant = Marshal.load(File.read(Rails.root + 'db/variant.marshal'))
  end
end

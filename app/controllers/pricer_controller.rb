class PricerController < ApplicationController
  layout false

  def index
    @search = PricerForm.new(params[:search])
    if @search.valid?
      @recommendations = @search.search.sort_by(&:price_total)
    end

  render :partial => 'recommendations'
  rescue Amadeus::AmadeusError, Handsoap::Fault => e
    @error_message = e.message
    render :index
  end
end


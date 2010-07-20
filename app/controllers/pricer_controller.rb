class PricerController < ApplicationController
  def index
    @search = PricerForm.new(params[:search])
    if @search.valid?
      @recommendations = @search.search.sort_by(&:price_total)
    end

    respond_to do |format|
      format.js {render :partial => 'recommendations', :layout => false}
      format.html
    end
  rescue Amadeus::AmadeusError, Handsoap::Fault => e
    @error_message = e.message
    render :index
  end
end


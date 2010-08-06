class PricerController < ApplicationController
  layout false

  def index
    @search = PricerForm.new(params[:search])
    if @search.valid?
      @recommendations = @search.search.sort_by(&:price_total)
      # все - временное
      @cheap_recommendation = Recommendation.cheap(@recommendations)
      @fast_recommendation = Recommendation.fast(@recommendations)
      @optimal_recommendation = @fast_recommendation
    end

  render :partial => 'recommendations'
  rescue Amadeus::AmadeusError, Handsoap::Fault => e
    @error_message = e.message
    render :text => @errorMessage
  end

  def validate
    @search = PricerForm.new(params[:search])
    render :json => {
      :valid => @search.valid?,
      :human => @search.human
    }
  end
end


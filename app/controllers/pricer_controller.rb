class PricerController < ApplicationController
  layout false

  def index
    if params[:code]
      unless fragment_exist?({ :action_suffix => params[:code]})
        render :nothing => true unless fragment_exist?({ :action_suffix => params[:code]})
        return
      end
      @code = params[:code]
    else
      @search = PricerForm.new(params[:search])
      if @search.valid?
        @recommendations = @search.search
        # TODO перенести в модель
        unless @search.nonstop?
          recommendations_nonstop = PricerForm.new( params[:search].merge(:nonstop => true)).search
          # только новые
          @recommendations |= recommendations_nonstop
        end
        @recommendations = @recommendations.sort_by(&:price_total)
        # все - временное
        @cheap_recommendation = Recommendation.cheap(@recommendations)
        @fast_recommendation = Recommendation.fast(@recommendations)
        @optimal_recommendation = @fast_recommendation
        @code = ShortUrl.generate_url(@recommendations.hash)
      end
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


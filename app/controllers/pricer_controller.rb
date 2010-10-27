class PricerController < ApplicationController
  layout false

  def index
    if params[:query_key]
      @query_key = params[:query_key]
    else
      #params[:search][:search_type] = 'calendar'
      #params[:search][:day_interval] = 3
      @search = PricerForm.new(params[:search])
      if @search.valid?
        @recommendations = @search.search
        # TODO перенести в модель
        unless @search.nonstop?
          recommendations_nonstop = PricerForm.new( params[:search].merge(:nonstop => true)).search
          # только новые
          @recommendations = Recommendation.merge(@recommendations, recommendations_nonstop)
        end
        # автобусы и поезда
        @recommendations.delete_if(&:ground?)
        @recommendations = @recommendations.sort_by(&:price_total)
        # все - временное
        @cheap_recommendation = Recommendation.cheap(@recommendations)
        @fast_recommendation = Recommendation.fast(@recommendations)
        @optimal_recommendation = @fast_recommendation
        @query_key = ShortUrl.generate_url(@recommendations.hash)
        Rails.cache.write('pricer_form' + @query_key, @search)
      end
    end
    
    render :partial => 'recommendations'
  rescue Amadeus::AmadeusError, Handsoap::Fault => e
    @error_message = e.message
    render :text => @errorMessage
  end

  def validate
    if params[:query_key]
      @search = Rails.cache.read('pricer_form' + params[:query_key])
      render :json => {
        :search => @search,
        :valid => @search.present? && @search.valid?,
        :human => @search && @search.human,
        :fragment_exist => fragment_exist?({:action => 'index', :action_suffix => params[:query_key]})
      }
    else
      @search = PricerForm.new(params[:search])
      render :json => {
        :valid => @search.valid?,
        :human => @search.human
      }
    end
  end
end


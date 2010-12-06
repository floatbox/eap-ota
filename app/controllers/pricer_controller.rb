class PricerController < ApplicationController
  layout false

  def index
    require "pricer_form"
    if params[:query_key]
      @query_key = params[:query_key]
      @search = Rails.cache.read('pricer_form' + params[:query_key])
      @search.search_type = params[:search_type]
    else
      @search = PricerForm.new(params[:search])
      @query_key = ShortUrl.generate_url([@search, Time.now].hash)
      Rails.cache.write('pricer_form' + @query_key, @search)
    end
    unless params[:restore_results]
      if @search.valid?
        @recommendations = @search.search
        # TODO перенести в модель
        if @search.search_type == 'travel' && !@search.nonstop?
          @search.nonstop = true
          recommendations_nonstop = @search.search
          # только новые
          @recommendations = Recommendation.merge(@recommendations, recommendations_nonstop)
        end
        # автобусы и поезда
        @recommendations.delete_if(&:ground?)
        @recommendations = @recommendations.sort_by(&:price_total)
        @locations = @search.human_locations
      end
    end
    if params[:search_type] == 'calendar'
      render :partial => 'matrix'
    else
      @recommendations = Recommendation.corrected @recommendations unless params[:restore_results]
      render :partial => 'recommendations'
    end
  rescue Amadeus::Error, Handsoap::Fault => e
    @error_message = e.message
    render :text => @errorMessage
  end


  def validate
    require 'pricer_form'
    if params[:query_key]
      @search = Rails.cache.read('pricer_form' + params[:query_key])
      fragment_exist = fragment_exist?({:action => 'index', :action_suffix => params[:query_key]}) &&
        fragment_exist?({:action => 'index', :action_suffix => ('matrix' + params[:query_key])})
      render :json => {
        :search => @search,
        :valid => @search.present? && @search.valid?,
        :human => @search && @search.human,
        :fragment_exist => fragment_exist
      }
    else
      @search = PricerForm.new(params[:search])
      @search.parse_complex_to
      if @search.valid?
        @query_key = ShortUrl.generate_url([@search, Time.now].hash)
        Rails.cache.write('pricer_form' + @query_key, @search)
      end
      render :json => {
        :valid => @search.valid?,
        :human => @search.human,
        :search => @search,
        :complex_to_parse_results => @search.complex_to_parse_results,
        :query_key => @query_key
      }
    end
  end
end


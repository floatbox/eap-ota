# encoding: utf-8
class PricerController < ApplicationController
  layout false

  def index
    #require 'Amadeus'
    if params[:query_key]
      @query_key = params[:query_key]
      @search = PricerForm.load_from_cache(params[:query_key])
      @search.search_type = params[:search_type]
    else
      render :text => 'PricerForm not found'
    end
    unless params[:restore_results]
      if @search.valid?
        # TODO перенести в модел
        if @search.search_type == 'travel'
          @recommendations = Amadeus::Request.for('fare_master_pricer_travel_board_search').from_pricer_form(@search).invoke.recommendations
          unless @search.nonstop?
            begin
              @search.nonstop = true
              recommendations_nonstop = Amadeus::Request.for('fare_master_pricer_travel_board_search').from_pricer_form(@search).invoke.recommendations
              # только новые
              @recommendations = Recommendation.merge(@recommendations, recommendations_nonstop)
            rescue
            end
          end
        else
           @recommendations = Amadeus::Request.for('fare_master_pricer_calendar').from_pricer_form(@search).invoke.recommendations
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
    if params[:query_key]
      @search = PricerForm.load_from_cache(params[:query_key])
      fragment_exist = fragment_exist?({:action => 'index', :action_suffix => params[:query_key]}) &&
        fragment_exist?({:action => 'index', :action_suffix => ('matrix' + params[:query_key])})
      render :json => {
        :search => @search,
        :valid => @search.present? && @search.valid?,
        :human => @search && @search.human,
        :fragment_exist => fragment_exist
      }
    else
      @search = PricerForm.new(params[:search].merge({:form_segments => []}))
      @search.form_segments = params[:search][:form_segments].to_a.sort_by{|a| a[0]}.map{|k, v| PricerForm::FormSegment.new(v)}
      @search.parse_complex_to
      if @search.valid?
        @query_key = ShortUrl.generate_url([@search, @search.form_segments, Time.now].hash)
        @search.save_to_cache(@query_key)
      end
      render :json => {
        :valid => @search.valid?,
        :errors => @search.form_segments.map{|fs| fs.errors.keys},
        :human => @search.human,
        :search => @search,
        :complex_to_parse_results => @search.complex_to_parse_results,
        :query_key => @query_key
      }
    end
  end
end


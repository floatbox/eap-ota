# encoding: utf-8
class PricerController < ApplicationController
  layout false

  before_filter :load_form_from_cache, :only => [:pricer, :calendar]

  def pricer
    if @search.valid?
      @destination = Destination.get_by_search @search
      @recommendations = Mux.new(:admin_user => admin_user).async_pricer(@search)
      if (@destination && @recommendations.present? && !admin_user && !corporate_mode?)
        @destination.move_average_price @search, @recommendations.first, @query_key
      end
      @locations = @search.human_locations
      @average_price = @destination.average_price * @search.people_count[:adults] if @destination && @destination.average_price
      StatCounters.d_inc @destination, %W[search.total search.pricer.total] if @destination
    end
    render :partial => 'recommendations'
  ensure
    StatCounters.inc %W[search.pricer.total]
  end

  def pricer_benchmark
    Recommendation.class
    Variant.class
    Segment.class
    Flight.class
    file_name = Rails.root + 'data/recommendations/rec.dump'
    file = File.open(file_name, 'r')
    @search = PricerForm.load_from_cache('pcu8mn')

    @recommendations = Marshal.load(file.read)
    @locations = @search.human_locations

    render :partial => 'recommendations'
  end

  def hot_offers
    # FIXME а когда здесь параметр должен был случаться?
    render :json => HotOffer.featured(params[:query_key])
  end

  def price_map
    hot_offers = Rails.cache.fetch("price_map_#{params[:from]}_#{params[:date]}_rt#{params[:rt]}", :expires_in => 3.minutes) do
        HotOffer.price_map(params[:from], params[:rt], params[:date])
    end
    render :json => hot_offers
  end

  def calendar
    if @search.valid? && @search.segments.size < 3
      @recommendations = Mux.new(:admin_user => admin_user).calendar(@search)
    end
    render :partial => 'matrix'
  ensure
    StatCounters.inc %W[search.calendar.total]
  end
  
  #FIXME сделать презентер
  include TranslationHelper
  include PricerFormHelper
  def validate
    result = {}
    if @query_key = params[:query_key]
      @search = PricerForm.load_from_cache(@query_key)
      #set_search_context_for_airbrake
      fragment_exist = fragment_exist?([:pricer, @query_key]) && fragment_exist?([:calendar, @query_key])
      result[:fragment_exist] = fragment_exist
      StatCounters.inc %W[validate.cached] if fragment_exist
    else
      @search = PricerForm.new(params[:search])
      #set_search_context_for_airbrake
      if @search.valid?
        StatCounters.inc %W[validate.success]      
        @search.save_to_cache
      else
        result[:errors] = @search.segments.map{|fs| fs.errors.keys}
      end
    end
    if @search.present?
      result[:map_segments] = @search.map_segments
    end
    if @search.present? && @search.valid?
      result.merge!(search_details(@search))
      result[:query_key] = @search.query_key
      result[:short] = @search.human_short
      result[:valid] = true
    end
    render :json => result
  ensure
    StatCounters.inc %W[validate.total]
  end

  # FIXME попытаться вынести общие методы или объединить с pricer/validate
  def api
    partner = params['partner'].to_s
    if !Conf.api.enabled || !Partner[partner].enabled?
      render 'api/error', :status => 503, :locals => {:message => 'service disabled by administrator'}
      return
    end
    pricer_form_hash = params.dup.delete_if {|key, value| %W[controller action format].include?(key)}
    @search = PricerForm.simple(pricer_form_hash)
    
    StatCounters.inc %W[search.api.total search.api.#{partner}.total]
    
    if @search.valid?
      @search.save_to_cache
      @destination = Destination.get_by_search @search
      suggested_limit =
        Partner[partner].suggested_limit ||
        Partner.anonymous.suggested_limit ||
        Conf.amadeus.recommendations_lite
      logger.info "Suggested limit: #{suggested_limit}"
      @recommendations = Mux.new(:lite => true, :suggested_limit => suggested_limit).pricer(@search)
      @query_key = @search.query_key
      if (@destination && @recommendations.present? && !admin_user && !corporate_mode?)
        @destination.move_average_price @search, @recommendations.first, @query_key
      end
      Recommendation.remove_unprofitable!(@recommendations, Partner[partner].try(:income_at_least))
      StatCounters.inc %W[search.api.success search.api.#{partner}.success]
      StatCounters.d_inc @destination, %W[search.total search.api.total search.api.#{partner}.total] if @destination
      # поправка на неопределенный @destination что бы сходились счетчики
      StatCounters.inc %W[search.api.#{partner}.bad_destination] if !@destination
      @cheat_partner = Partner[partner] && Partner[partner].cheat
      render 'api/variants'
    else
      StatCounters.inc %W[search.api.invalid search.api.#{partner}.invalid]
      @recommendations = []

      render 'api/variants'
    end
  rescue IataStash::NotFound => iata_error
    render 'api/error', :status => 404, :locals => {:message => iata_error.message}
  rescue ArgumentError => argument_error
    render 'api/error', :status => 400, :locals => {:message => argument_error.message}
  end

  protected

  def load_form_from_cache
    StatCounters.inc %W[search.total]
    unless (@query_key = params[:query_key]) && (@search = PricerForm.load_from_cache(@query_key))
      StatCounters.inc %W[search.errors.pricer_form_not_found]
      render :text => "404 Not found", :status => :not_found
    end
    #set_search_context_for_airbrake
  end

end


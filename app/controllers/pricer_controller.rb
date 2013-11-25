# encoding: utf-8
class PricerController < ApplicationController
  layout false

  before_filter :parse_and_validate_url, :only => [:pricer, :calendar]
  around_filter :enforce_timeout, only: [:pricer, :api]

  include Monitoring::Benchmarkable

  def pricer
    @context = Context.new(deck_user: current_deck_user)
    @destination = Destination.get_by_search @search
    @recommendations = Mux.new(context: @context).async_pricer(@search)
    if (@destination && @recommendations.present? && !admin_user)
      @destination.move_average_price @search, @recommendations.cheapest, @code
    end
    @locations = @search.human_locations
    @average_price = @destination.average_price * @search.people_count[:adults] if @destination && @destination.average_price
    StatCounters.d_inc @destination, %W[search.total search.pricer.total] if @destination
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
    @search = AviaSearch.from_code('Y100MOWAMS17SEP')

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
    @context = Context.new(deck_user: current_deck_user)
    if @search.segments.size < 3
      @recommendations = Mux.new(context: @context).calendar(@search)
    end
    render :partial => 'matrix'
  ensure
    StatCounters.inc %W[search.calendar.total]
  end

  #FIXME сделать презентер
  include TranslationHelper
  def validate
    result = {}
    if @query_key = params[:query_key]
      @search = AviaSearch.from_code(@query_key)
      unless @search && @search.valid?
        result[:errors] = ['parsing error']
      end
    else
      @search = AviaSearch.from_js(params[:search])
      unless @search.valid?
        result[:errors] = @search.segments.flat_map(&:errors)
      end
    end
    if @search.present?
      result[:map_segments] = @search.map_segments
    end
    if @search && @search.valid?
      result.merge!(@search.details)
      result[:query_key] = Search::Urls::Encoder.new(@search).url
      result[:short] = @search.human_short
      result[:valid] = true
    end
    render :json => result
  ensure
    StatCounters.inc %W[validate.total]
  end

  # FIXME попытаться вынести общие методы или объединить с pricer/validate
  def api
    @context = Context.new(partner: params[:partner], robot: true)
    if !Conf.api.enabled || !@context.pricer_enabled?
      render 'api/error', :status => 503, :locals => {:message => 'service disabled by administrator'}
      return
    end
    avia_search_hash = params.dup.delete_if {|key, value| %W[controller action format].include?(key)}
    @search = AviaSearch.simple(avia_search_hash)

    StatCounters.inc %W[search.api.total search.api.#{@context.partner_code}.total]

    if @search.valid?
      @destination = Destination.get_by_search @search
      @recommendations = Mux.new(context: @context).pricer(@search)

      # измеряем рекомендации до фильтрации
      meter :api_total_unfiltered_recommendations, @recommendations.size

      @code = @search.encode_url
      if (@destination && @recommendations.present?)
        @destination.move_average_price @search, @recommendations.cheapest, @code
      end

      Recommendation.remove_unprofitable!(@recommendations, @context.partner.income_at_least)

      recommendations_total = @recommendations.size
      # измеряем после фильтрации
      meter :api_total_recommendations, recommendations_total

      logger.info "Recommendations left after removing unprofitable(#{@context.partner_code}): #{recommendations_total}"
      StatCounters.inc %W[search.api.success search.api.#{@context.partner_code}.success]
      logger.info "Increment counter search.api.success for partner #{@context.partner_code}"
      StatCounters.d_inc @destination, %W[search.total search.api.total search.api.#{@context.partner_code}.total] if @destination
      # поправка на неопределенный @destination что бы сходились счетчики
      StatCounters.inc %W[search.api.#{@context.partner_code}.bad_destination] if !@destination
      # FIXME пофиксить Recommendation.price_for_partner
      @partner = @context.partner
      render 'api/variants'
    else
      StatCounters.inc %W[search.api.invalid search.api.#{@context.partner_code}.invalid]
      logger.info "Invalid API search with params #{avia_search_hash} validation errors: #{@search.errors.full_messages}"
      @recommendations = []
      render 'api/variants'
    end
  rescue CodeStash::NotFound => iata_error
    render 'api/error', :status => 404, :locals => {:message => iata_error.message}
  rescue ArgumentError => argument_error
    render 'api/error', :status => 400, :locals => {:message => argument_error.message}
  rescue Timeout::Error, ActiveRecord::StatementInvalid => e
    render 'api/error', :status => 500, :locals => {:message => 'Execution expired'}
  end

  protected

  def parse_and_validate_url
    StatCounters.inc %W[search.total]
    @code = params[:query_key]
    unless @search = AviaSearch.from_code(@code)
      StatCounters.inc %W[search.errors.coded_url_is_broken]
      render :text => "404 Not found", :status => :not_found
    end
  end

end


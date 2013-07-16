# encoding: utf-8
class PricerController < ApplicationController
  layout false

  before_filter :parse_and_validate_url, :only => [:pricer, :calendar]

  include Monitoring::Benchmarkable

  def pricer
    @search.partner = params[:partner]
    @destination = Destination.get_by_iatas @search
    @recommendations = Mux.new(:admin_user => admin_user).async_pricer(@search)
    if (@destination && @recommendations.present? && !admin_user && !corporate_mode?)
      @destination.move_average_price @search, @recommendations.first, @code
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
    @search = PricerForm.from_code('Y100MOWAMS17SEP')

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
    if @search.segments.size < 3
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
      #set_search_context_for_airbrake
      @search = PricerForm.from_code(@query_key)
      fragment_exist = fragment_exist?([:pricer, @query_key]) && fragment_exist?([:calendar, @query_key])
      result[:fragment_exist] = fragment_exist
      StatCounters.inc %W[validate.cached] if fragment_exist
    else
      @search = PricerForm.new(params[:search])
      #set_search_context_for_airbrake
      unless @search.valid?
        result[:errors] = @search.segments.map{|fs| fs.errors.keys}
      end
    end
    if @search.present?
      result[:map_segments] = @search.map_segments
    end
    if @search.present? && @search.valid?
      result.merge!(search_details(@search))
      result[:query_key] = Urls::Search::Encoder.new(@search).url
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
    partner4stat = partner.blank? ? 'anonymous' : partner
    if !Conf.api.enabled || !Partner[partner].enabled?
      render 'api/error', :status => 503, :locals => {:message => 'service disabled by administrator'}
      return
    end
    pricer_form_hash = params.dup.delete_if {|key, value| %W[controller action format].include?(key)}
    @search = PricerForm.simple(pricer_form_hash)
    
    StatCounters.inc %W[search.api.total search.api.#{partner4stat}.total]

    if @search.valid?
      @destination = Destination.get_by_search @search
      suggested_limit =
        Partner[partner].suggested_limit ||
        Partner.anonymous.suggested_limit ||
        Conf.amadeus.recommendations_lite
      logger.info "Suggested limit: #{suggested_limit}"

      @recommendations = Mux.new(:lite => true, :suggested_limit => suggested_limit).pricer(@search)

      # измеряем рекомендации до фильтрации
      meter :api_total_unfiltered_recommendations, @recommendations.size

      @code = @search.encode_url
      if (@destination && @recommendations.present? && !admin_user && !corporate_mode?)
        @destination.move_average_price @search, @recommendations.first, @code
      end

      Recommendation.remove_unprofitable!(@recommendations, Partner[partner].try(:income_at_least))

      recommendations_total = @recommendations.count
      # измеряем после фильтрации
      meter :api_total_recommendations, recommendations_total

      logger.info "Recommendations left after removing unprofitable(#{partner4stat}): #{recommendations_total}"
      StatCounters.inc %W[search.api.success search.api.#{partner4stat}.success]
      logger.info "Increment counter search.api.success for partner #{partner4stat}"
      StatCounters.d_inc @destination, %W[search.total search.api.total search.api.#{partner4stat}.total] if @destination
      # поправка на неопределенный @destination что бы сходились счетчики
      StatCounters.inc %W[search.api.#{partner4stat}.bad_destination] if !@destination
      @cheat_partner = Partner[partner] && Partner[partner].cheat
      render 'api/variants'
    else
      StatCounters.inc %W[search.api.invalid search.api.#{partner4stat}.invalid]
      logger.info "Invalid API search with params #{pricer_form_hash} validation errors: #{@search.errors.full_messages}"
      @recommendations = []
      render 'api/variants'
    end
  rescue IataStash::NotFound => iata_error
    render 'api/error', :status => 404, :locals => {:message => iata_error.message}
  rescue ArgumentError => argument_error
    render 'api/error', :status => 400, :locals => {:message => argument_error.message}
  end

  protected

  def parse_and_validate_url
    StatCounters.inc %W[search.total]
    @code = params[:query_key]
    unless @search = PricerForm.from_code(@code)
      StatCounters.inc %W[search.errors.coded_url_is_broken]
      render :text => "404 Not found", :status => :not_found
    end
  end

end


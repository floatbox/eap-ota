# encoding: utf-8
class PricerController < ApplicationController
  layout false

  before_filter :load_form_from_cache, :only => [:pricer, :calendar]

  def pricer
    unless params[:restore_results]
      if @search.valid?
        @destination = get_destination
        @recommendations = Mux.new(:admin_user => admin_user).async_pricer(@search)
        @locations = @search.human_locations
        hot_offer = create_hot_offer
        @average_price = hot_offer.destination.average_price * @search.people_count[:adults] if hot_offer
        StatCounters.d_inc @destination, %W[search.total search.pricer.total] if @destination
      end
    end
    render :partial => 'recommendations'
  ensure
    StatCounters.inc %W[search.pricer.total]
  end

  def hot_offers
    # FIXME а когда здесь параметр должен был случаться?
    render :json => HotOffer.featured(params[:query_key])
  end

  def calendar
    unless params[:restore_results]
      if @search.valid? && @search.segments.size < 3
        @recommendations = Mux.new(:admin_user => admin_user).calendar(@search)
      end
    end
    render :partial => 'matrix'
  ensure
    StatCounters.inc %W[search.calendar.total]
  end

  def validate
    if @query_key = params[:query_key]
      @search = PricerForm.load_from_cache(@query_key)
      #set_search_context_for_airbrake
      fragment_exist =
        fragment_exist?([:pricer, @query_key]) &&
        fragment_exist?([:calendar, @query_key])
      StatCounters.inc %W[validate.cached] if fragment_exist
      render :json => {
        :search => @search,
        :valid => @search.present? && @search.valid?,
        :human => @search && @search.human,
        :fragment_exist => fragment_exist
      }
    else
      @search = PricerForm.new(params[:search])
      #set_search_context_for_airbrake
      if @search.valid?
        StatCounters.inc %W[validate.success]
        @search.save_to_cache
      end
      render :json => {
        :valid => @search.valid?,
        :errors => @search.segments.map{|fs| fs.errors.keys},
        :human => @search.human,
        :search => @search,
        :complex_to_parse_results => @search.complex_to_parse_results,
        :query_key => @search.query_key
      }
    end
  ensure
    StatCounters.inc %W[validate.total]
  end

  # FIXME попытаться вынести общие методы или объединить с pricer/validate
  def api
    partner = params['partner'].to_s
    if !Conf.api.enabled || Partner.this_name_is_off?(partner)
      render 'api/yandex_failure', :status => 503, :locals => {:message => 'service disabled by administrator'}
      return
    end
    pricer_form_hash = params.dup.delete_if {|key, value| %W[controller action format].include?(key)}
    @search = PricerForm.simple(pricer_form_hash)
    
    StatCounters.inc %W[search.api.total search.api.#{partner}.total]
    
    if @search.valid?
      @search.save_to_cache
      @destination = get_destination
      @recommendations = Mux.new(:lite => true).async_pricer(@search)
      StatCounters.inc %W[search.api.success search.api.#{partner}.success]
      StatCounters.d_inc @destination, %W[search.total search.api.total search.api.#{partner}.total] if @destination
      render 'api/yandex'
    else
      @recommendations = []
      render 'api/yandex'
    end
  rescue IataStash::NotFound => iata_error
    render 'api/yandex_failure', :status => 404, :locals => {:message => iata_error.message}
  rescue ArgumentError => argument_error
    render 'api/yandex_failure', :status => 400, :locals => {:message => argument_error.message}
  end

  protected

  def create_hot_offer
    if (@recommendations.present? && !@search.complex_route? &&
        @search.people_count.values.sum == @search.people_count[:adults] &&
        !admin_user &&
        !corporate_mode? &&
        ([nil, '', 'Y'].include? @search.cabin) &&
        @search.segments[0].to_as_object.class == City && @search.segments[0].from_as_object.class == City
      )
       HotOffer.create(
          :code => @query_key,
          :search => @search,
          :recommendation => @recommendations.first,
          :url => (url_for(:action => :index, :controller => :home) + '#' + @query_key),
          :price => @recommendations.first.price_with_payment_commission / @search.people_count.values.sum)
    end
  end

  def get_destination
    segment = @search.segments[0]
    return if ([segment.to_as_object.class, segment.from_as_object.class] - [City, Airport]).present? || @search.complex_route?
    to = segment.to_as_object.class == Airport ? segment.to_as_object.city : segment.to_as_object
    from = segment.from_as_object.class == Airport ? segment.from_as_object.city : segment.from_as_object
    Destination.find_or_create_by(:from_iata => from.iata, :to_iata => to.iata , :rt => @search.rt)
  end

  def load_form_from_cache
    StatCounters.inc %W[search.total]
    unless (@query_key = params[:query_key]) && (@search = PricerForm.load_from_cache(@query_key))
      StatCounters.inc %W[search.errors.pricer_form_not_found]
      render :text => "404 Not found", :status => :not_found
    end
    #set_search_context_for_airbrake
  end

end


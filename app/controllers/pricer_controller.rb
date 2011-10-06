# encoding: utf-8
class PricerController < ApplicationController
  layout false

  before_filter :load_form_from_cache, :only => [:pricer, :calendar]

  def pricer
    unless params[:restore_results]
      if @search.valid?
        @recommendations = Mux.new(:admin_user => admin_user).async_pricer(@search)
        @locations = @search.human_locations
        hot_offer = create_hot_offer
        @average_price = hot_offer.destination.average_price * @search.people_count[:adults] if hot_offer
      end
    end
    render :partial => 'recommendations'
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
  end

  def validate
    if @query_key = params[:query_key]
      @search = PricerForm.load_from_cache(@query_key)
      set_search_context_for_hoptoad
      fragment_exist =
        fragment_exist?([:pricer, @query_key]) &&
        fragment_exist?([:calendar, @query_key])
      render :json => {
        :search => @search,
        :valid => @search.present? && @search.valid?,
        :human => @search && @search.human,
        :fragment_exist => fragment_exist
      }
    else
      @search = PricerForm.new(params[:search])
      set_search_context_for_hoptoad
      if @search.valid?
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
  end

  # FIXME попытаться вынести общие методы или объединить с pricer/validate
  def api
    unless Conf.api.enabled
      render 'api/yandex_failure', :status => 503, :locals => {:message => 'service disabled by administrator'}
      return
    end
    pricer_form_hash = params.dup.delete_if {|key, value| %W[controller action format].include?(key)}
    @search = PricerForm.simple(pricer_form_hash)
    if @search.valid?
      @search.save_to_cache
      @recommendations = Mux.new(:lite => true).async_pricer(@search)
      render 'api/yandex'
    elsif @search.errors[:"segments.date"] == ["Первый вылет слишком рано"]
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
          :url => (url_for(:action => :index, :controller => :home) + '#' + @query_key )
        )
    end
  end


  def load_form_from_cache
    @query_key = params[:query_key] or raise 'no query_key provided'
    @search = PricerForm.load_from_cache(params[:query_key])
    set_search_context_for_hoptoad
  end

end


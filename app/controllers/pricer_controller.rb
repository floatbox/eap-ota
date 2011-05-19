# encoding: utf-8
class PricerController < ApplicationController
  layout false

  before_filter :load_form_from_cache, :only => [:pricer, :calendar]

  def pricer
    unless params[:restore_results]
      if @search.valid?
        @recommendations = Mux.pricer(@search, admin_user)
        @locations = @search.human_locations
        hot_offer = create_hot_offer
        @average_price = hot_offer.destination.average_price if hot_offer
      end
    end
    render :partial => 'recommendations'
  end

  def hot_offers
    render :json => HotOffer.find(:all, :conditions => ["code != ? AND for_stats_only = ? AND price_variation < 0", params[:query_key].to_s, false], :limit => 30, :order => 'created_at DESC').group_by(&:destination_id).values.every.first
  end

  def calendar
    unless params[:restore_results]
      if @search.valid? && @search.form_segments.size < 3
        @recommendations = Mux.calendar(@search, admin_user)
      end
    end
    render :partial => 'matrix'
  end

  def validate
    if @query_key = params[:query_key]
      @search = PricerForm.load_from_cache(@query_key)
      set_search_context
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
      set_search_context
      if @search.valid?
        @search.save_to_cache
      end
      render :json => {
        :valid => @search.valid?,
        :errors => @search.form_segments.map{|fs| fs.errors.keys},
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
      render :status => 503, :text => '<error>service disabled by administrator</error>'
      return
    end
    @search = PricerForm.simple( params.slice(:from, :to, :date1, :date2, :adults, :children, :infants, :seated_infants, :cabin) )
    @search.partner = params[:partner] || 'unknown'
    if @search.valid?
      @search.save_to_cache
      @recommendations = Mux.pricer(@search, false, true)
      render 'api/yandex'
    else
      render 'api/yandex_failure', :locals => {:message => 'from, to and date1 parameters are required'}
    end
  end

  protected

  def create_hot_offer
    if (@recommendations.present? && !@search.complex_route? &&
        @search.people_count.values.sum == @search.people_count[:adults] &&
        !admin_user &&
        ([nil, '', 'Y'].include? @search.cabin) &&
        @search.form_segments[0].to_as_object.class == City && @search.form_segments[0].from_as_object.class == City
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
    set_search_context
  end

end


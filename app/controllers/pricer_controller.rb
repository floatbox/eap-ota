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
    render :json => HotOffer.find(:all, :conditions => ["code != ? AND for_stats_only = ?", params[:query_key].to_s, false], :limit => 20, :order => 'created_at DESC', :group => 'destination_id')
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
      @search.parse_complex_to
      if @search.valid?
        @query_key = ShortUrl.random_hash
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
  end
end


# encoding: utf-8
class PricerController < ApplicationController
  layout false

  before_filter :load_form_from_cache, :only => [:pricer, :calendar]

  def pricer
    unless params[:restore_results]
      if @search.valid?
        @recommendations = Mux.pricer(@search, admin_user)
        @locations = @search.human_locations
      end
    end

    render :partial => 'recommendations'
  end

  def calendar
    unless params[:restore_results]
      if @search.valid? && @search.form_segments.size < 3
        @recommendations = Mux.calendar(@search)
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

  protected

  def load_form_from_cache
    @query_key = params[:query_key] or raise 'no query_key provided'
    @search = PricerForm.load_from_cache(params[:query_key])
  end
end


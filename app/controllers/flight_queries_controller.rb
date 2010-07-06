class FlightQueriesController < ApplicationController
  def default
    @query = FlightQuery.new :from => Location.default

    render :json => {
      :success => true,
      :data => [@query]
    }
  end

  def show
    if @preset = Preset.find_by_name(params[:id])
      render :json => {
        :success => true,
        :data => [@preset.query]
      }
    else
      render :json => {
        :success => false,
        :data => [],
        :message => 'no such query'
      }
    end
  end

  def geo
    @location = Location.search(params[:location]).first
    if @location
      @query = FlightQuery.new :to => @location, :from => Location.default
      @query.date = {
        :date1 => [1.day.from_now.to_date],
        :date2 => [8.days.from_now.to_date]
      }
      render :json => {
        :success => true,
        :data => [@query]
      }
    else
      render :json => {
        :success => false,
        :data => [],
        :message => 'no such location'
      }
    end
  end

  def update
    @preset = Preset.find_or_initialize_by_name(params[:id])
    @preset.query = FlightQuery.new(params[:query])
    @preset.save!
    render :json => {
      #:location => url_for(@preset),
      :success => true
    }
  end

  def presets
    @presets = Preset.all
    @queries = @presets.map(&:query)

    respond_to do |wants|
      wants.html { render :layout => false }
      wants.json do
        render :json => {
          :success => true,
          :data => @queries
        }
      end
    end
  end
end

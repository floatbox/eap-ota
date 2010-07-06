class OffersController < ApplicationController

  def filter
    @query = FlightQuery.new(params[:query])

    @offers = @query.results

    render :json => {
      :success => true,
      :query => @query,
      :stats => @query.stats,
      :as_text => @query.to_s,
      :total => @offers.size,
      :calendar => @query.calendar,
      :valid => @query.valid?,
      :offers => @offers
    }
  end

  def grok
    @query = FlightQuery.new(params[:query])

    render :json => {
      :success => true,
      :query => @query,
      :as_text => @query.to_s,
      :calendar => @query.calendar,
      :valid => @query.valid?
    }
  end

end

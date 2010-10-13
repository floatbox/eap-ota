class LocationsController < ApplicationController
  def index

    @locations = Location.quick_search(params[:filter])

    render :json => {
      :locations => @locations,
      :total => @locations.size
    }
  end

  def current
    @location = City.find_by_iata('MOW') || City.first
    render :json => @location
  end
end

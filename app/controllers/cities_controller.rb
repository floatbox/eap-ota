class CitiesController < ApplicationController
  # GET /cities
  # GET /cities.json
  def index
    if params[:prefix]
      @cities = City.prefixed(params[:prefix]).limited(10)
    else
      @cities = City.limited(10)
    end

    respond_to do |format|
      format.json  { render :json => {:cities => @cities}}
    end
  end

  # GET /cities/1
  # GET /cities/1.json
  def show
    @city = City.find(params[:id])

    respond_to do |format|
      format.json  { render :json => @city }
    end
  end

  def random
    @city = City.random
    render :json => @city
  end
end

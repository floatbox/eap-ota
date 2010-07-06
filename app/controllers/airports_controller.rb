class AirportsController < ApplicationController
  # GET /airports
  # GET /airports.json
  def index
    if params[:filter]
      @airports = Airport.prefixed(params[:filter]).limited(100)
    else
      @airports = Airport.limited(100)
    end

    respond_to do |format|
      format.json  { render :json => {:airports => @airports, :total => @airports.size }}
    end
  end


  # GET /airports/1
  # GET /airports/1.json
  def show
    @airport = Airport.find(params[:id])

    respond_to do |format|
      format.json  { render :json => @airport }
    end
  end

  def random
    @airport = Airport.random
    render :json => @airport
  end
end

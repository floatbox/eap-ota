class AirlinesController < ApplicationController
  # GET /airlines
  # GET /airlines.json
  def index
    if params[:filter]
      @airlines = Airline.prefixed(params[:filter]).limited(100)
    else
      @airlines = Airline.all
    end

    respond_to do |format|
      format.json  { render :json => {:airlines => @airlines, :total => @airlines.size }}
    end
  end

  # GET /airlines/1
  # GET /airlines/1.json
  def show
    @airline = Airline.find(params[:id])

    respond_to do |format|
      format.json  { render :json => @airline }
    end
  end
end

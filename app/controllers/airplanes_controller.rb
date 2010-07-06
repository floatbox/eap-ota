class AirplanesController < ApplicationController
  # GET /airplanes
  # GET /airplanes.json
  def index
    if params[:filter]
      @airplanes = Airplane.prefixed(params[:filter]).limited(100)
    else
      @airplanes = Airplane.limited(100)
    end

    respond_to do |format|
      format.json  { render :json => {:airplanes => @airplanes, :total => @airplanes.size }}
    end
  end

  # GET /airplanes/1
  # GET /airplanes/1.json
  def show
    @airplane = Airplane.find(params[:id])

    respond_to do |format|
      format.json  { render :json => @airplane }
    end
  end
end

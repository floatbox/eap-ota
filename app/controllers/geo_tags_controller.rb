class GeoTagsController < ApplicationController
  # GET /geo_tags
  # GET /geo_tags.json
  def index
    @geo_tags = GeoTag.all :order => :name

    respond_to do |format|
      format.json  { render :json => {:geo_tags => @geo_tags}}
    end
  end

  # GET /geo_tags/1
  # GET /geo_tags/1.json
  def show
    @geo_tag = GeoTag.find(params[:id])

    respond_to do |format|
      format.json  { render :json => @geo_tag }
    end
  end

end

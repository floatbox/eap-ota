class CountriesController < ApplicationController
  def index
    @countries = Country.all
    respond_to do |format|
      format.json do
        render :json => {
          :countries => @countries,
          :total => @countries.size
        }
      end
    end
  end
  
  def show
    @country = Country.find(params[:id])
  end

  def random
    @country = Country.random
    render :json => @country
  end
end

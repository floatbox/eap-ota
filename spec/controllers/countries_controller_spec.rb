require 'spec_helper'

describe CountriesController do

  it "should return success on get to index" do
    get :index
    response.should be_success
  end

end

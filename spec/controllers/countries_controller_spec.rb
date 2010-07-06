require 'spec_helper'

describe CountriesController do

  it "should return success on get to random" do
    get :random
    response.should be_success
  end

end

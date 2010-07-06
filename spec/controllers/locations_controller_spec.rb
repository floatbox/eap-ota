require 'spec_helper'

describe LocationsController do

  it "should return success on get to random" do
    get :random
    response.should be_success
  end

  it "should return success on get to current" do
    get :current
    response.should be_success
  end

end

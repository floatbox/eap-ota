require 'spec_helper'

describe FlightQueriesController do

  it "should return success on get to random" do
    get :default
    response.should be_success
  end


end

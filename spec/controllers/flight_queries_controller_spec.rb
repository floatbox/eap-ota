require 'spec_helper'

describe FlightQueriesController do

  it "should return success on get to index" do
    get :index
    response.should be_success
  end


end

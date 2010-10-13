require 'spec_helper'

describe LocationsController do

  it "should return success on get to current" do
    get :current
    response.should be_success
  end

end

require 'spec_helper'

describe CitiesController do

  it "should return success on get to index" do
    get :index
    response.should be_success
  end

end

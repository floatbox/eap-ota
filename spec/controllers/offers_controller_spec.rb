require 'spec_helper'

describe OffersController do

  before :each do
    @from = Airport.create!
    @to = City.create!
  end

  def valid_query
    {:query => {
      :from => { :kind => 'airport', :id => @from.id.to_s },
      :to => { :kind => 'country', :id => @to.id.to_s },
      :date => { :date1 => ['2009.12.12'], :date2 => ['2009.12.14'] },
      #:airplane =>
      #:passengers
      #:time
      :price => {:value => "12", :currency => "RUB"}
    }}
  end

  it "should return success on post to offers/filter" do
    post :filter, valid_query
    response.should be_success
  end

  it "should return some flights on post to offers/filter" do
    post :filter, valid_query
    assigns[:flights].should_not be_nil
  end
end

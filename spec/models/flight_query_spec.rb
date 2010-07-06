require 'spec_helper'

describe FlightQuery do
  before :each do
    @from_location = City.create! :name_ru => 'city1'
    @to_location = City.create! :name_ru => 'city2'
    @valid_attributes = {
      :from => {:id => @from_location.id, :kind => @to_location.kind },
      :to => {:id => @to_location.id, :kind => @to_location.kind },
      :date => {
        :date1 => ['30.11.2009'],
        :date2 => ['1.12.2009']
      }
    }
  end

  it "should initialize properly" do
    FlightQuery.new(@valid_attributes)
  end

  it "should return correct stringification" do
    FlightQuery.new(@valid_attributes).to_s.should == "из city1 в city2 с 2009-11-30 по 2009-12-01"
    # 'с 30.11.2009 по 1.12.2009'
  end
end

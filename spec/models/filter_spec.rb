require 'spec_helper'

describe Filter::Date do
  before :each do
    @valid_attributes = {
      :date1 => ['30.11.2009','1.12.2009'],
      :date2 => ['1.12.2009','2.12.2009']
    }
  end

  it "should initialize properly" do
    Filter::Date.new(@valid_attributes)
  end

  it "should return correct stringification" do
    Filter::Date.new(@valid_attributes).to_s.should == "с 2009-11-30 по 2009-12-01"
    # 'с 30.11.2009 по 1.12.2009'
  end
end

# encoding: utf-8
require 'spec_helper'


describe TimeChecker do

  it "should define correctly if recommendation is sellable" do

    TimeChecker.stub!(:nearest_ticketing_time).and_return(Date.today + 10.hours)
    TimeChecker.ok_to_sell(Date.today + 11.hours).should_not be_true
    TimeChecker.ok_to_sell(Date.today + 13.hours).should be_true

    TimeChecker.stub!(:nearest_ticketing_time).and_return(Date.today + 1.day + 9.hours)
    TimeChecker.ok_to_sell(Date.today + 1.day + 12.hours, Date.today ).should_not be_true
    TimeChecker.ok_to_sell(Date.today + 1.day + 12.hours).should be_true
    TimeChecker.ok_to_sell(Date.today + 1.day + 12.hours, Date.today + 1.day).should be_true

  end


  it "should determine nearest ticketing time correctly" do
    night_time = Date.today + 10.minutes
    morning_time = Date.today + 10.hours
    evening_time = Date.today + 21.hours

    Time.stub!(:now).and_return(night_time)
    TimeChecker.nearest_ticketing_time.should == Date.today + 9.hours

    Time.stub!(:now).and_return(morning_time)
    TimeChecker.nearest_ticketing_time.should == morning_time

    Time.stub!(:now).and_return(evening_time)
    TimeChecker.nearest_ticketing_time.should == Date.today + 1.day + 9.hours
  end
end


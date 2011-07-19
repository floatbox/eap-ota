# encoding: utf-8
require 'spec_helper'


describe TimeChecker do

  context "should define correctly if recommendation is sellable" do

      night_time = Date.today + 10.minutes
      TimeChecker.ok_to_sell(night_time + 25.hours, Date.today, night_time).should == true
      TimeChecker.ok_to_sell(night_time + 23.hours, nil, night_time).should_not == true

      morning_time = Date.today + 10.hours
      TimeChecker.ok_to_sell(morning_time + 5.hours, Date.today, morning_time).should == true
      TimeChecker.ok_to_sell(morning_time + 3.hours, nil, morning_time).should_not == true

      evening_time = Date.today + 21.hours
      TimeChecker.ok_to_sell(evening_time + 25.hours, Date.today, evening_time).should == false
      TimeChecker.ok_to_sell(evening_time + 23.hours, Date.today, evening_time).should == false
      TimeChecker.ok_to_sell(evening_time + 23.hours, nil, evening_time).should == false
      TimeChecker.ok_to_sell(evening_time + 25.hours, nil, evening_time).should == true


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


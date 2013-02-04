# encoding: utf-8
require 'spec_helper'


describe TimeChecker do

  it "should define correctly if recommendation is sellable" do
    if TimeChecker::WORK_START_HOUR != TimeChecker::WORK_END_HOUR
      night_time = Date.today + TimeChecker::WORK_START_HOUR.hours - 1.minute
      TimeChecker.ok_to_sell(night_time + 25.hours, Date.today, night_time).should == true
      TimeChecker.ok_to_sell(night_time + 23.hours, nil, night_time).should_not == true
    end

    morning_time = Date.today + TimeChecker::WORK_START_HOUR.hours
    TimeChecker.ok_to_sell(morning_time + 5.hours, Date.today, morning_time).should == true
    TimeChecker.ok_to_sell(morning_time + 3.hours, nil, morning_time).should_not == true

    if TimeChecker::WORK_START_HOUR < TimeChecker::WORK_END_HOUR
      evening_time = Date.today + TimeChecker::WORK_END_HOUR.hours + 10.minutes
      TimeChecker.ok_to_sell(evening_time + 25.hours, Date.today, evening_time).should == false
      TimeChecker.ok_to_sell(evening_time + 23.hours, Date.today, evening_time).should == false
      TimeChecker.ok_to_sell(evening_time + 23.hours, nil, evening_time).should == false
      TimeChecker.ok_to_sell(evening_time + 25.hours, nil, evening_time).should == true
    end
  end


  it "should determine nearest ticketing time correctly" do
    evening_time = Date.today + 21.hours


    if TimeChecker::WORK_START_HOUR != TimeChecker::WORK_END_HOUR
      night_time = Date.today + TimeChecker::WORK_START_HOUR.hours - 1.minute
      Time.stub!(:now).and_return(night_time)
      TimeChecker.nearest_ticketing_time.should == Date.today + TimeChecker::WORK_START_HOUR.hours
    end

    morning_time = Date.today + TimeChecker::WORK_START_HOUR.hours
    Time.stub!(:now).and_return(morning_time)
    TimeChecker.nearest_ticketing_time.should == morning_time

    if TimeChecker::WORK_START_HOUR < TimeChecker::WORK_END_HOUR
      evening_time = Date.today + TimeChecker::WORK_END_HOUR.hours + 10.minutes
      Time.stub!(:now).and_return(evening_time)
      TimeChecker.nearest_ticketing_time.should == Date.tomorrow + TimeChecker::WORK_START_HOUR.hours
    end
  end
end


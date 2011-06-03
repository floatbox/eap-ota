# encoding: utf-8
require 'spec_helper'


describe TimeChecker do

  it "should define correctly if recommendation is sellabele" do
    morning_time = Date.today + 10.hours
    evening_time = Date.today + 18.hours
    late_time = Date.today + 20.hours + 31.minutes
    Time.stub!(:now).and_return(morning_time)

    [nil, Date.today, Date.today + 1.day].each do |last_tkt_date|
      TimeChecker.ok_to_sell(Date.today + 2.days, last_tkt_date).should == true
      TimeChecker.ok_to_sell(Date.today + 1.days, last_tkt_date).should == true
      TimeChecker.ok_to_sell(Date.today, last_tkt_date).should == false
    end

    Time.stub!(:now).and_return(evening_time)
    [nil, Date.today, Date.today + 1.day].each do |last_tkt_date|
      TimeChecker.ok_to_sell(Date.today + 2.days, last_tkt_date).should == true
      TimeChecker.ok_to_sell(Date.today + 1.days, last_tkt_date).should == false
      TimeChecker.ok_to_sell(Date.today, last_tkt_date).should == false
    end

    Time.stub!(:now).and_return(late_time)

    TimeChecker.ok_to_sell(Date.today + 2.days, nil).should == true
    TimeChecker.ok_to_sell(Date.today + 2.days, Date.today + 1.day).should == true

    TimeChecker.ok_to_sell(Date.today, Date.today).should == false
    TimeChecker.ok_to_sell(Date.today, Date.today + 1.day).should == false
    TimeChecker.ok_to_sell(Date.today, nil).should == false

    TimeChecker.ok_to_sell(Date.today + 1.day, Date.today).should == false
    TimeChecker.ok_to_sell(Date.today + 1.day, Date.today + 1.day).should == false
    TimeChecker.ok_to_sell(Date.today + 1.day, nil).should == false

    TimeChecker.ok_to_sell(Date.today + 2.day, Date.today).should == false

  end
end


# encoding: utf-8
require 'spec_helper'
describe Commission::Correctors do

  include Commission::Fx

  describe ":twopercent" do
    let :commission_class do
      Class.new do
        include Commission::Rules
        defaults :corrector => :twopercent, :consolidator => '2%'

        # авиацентр не берет доп комиссию
        carrier 'FV'
        commission '0 3%'

        # авиацентр берет доп комиссию если в рублях и меньше или равно 5
        carrier 'AB'
        commission '0 5'

        # авиацентр не берет доп комиссию если больше 5
        carrier 'AF'
        commission '0 6'

        # авиацентр берет измененную доп комиссию
        carrier 'HR'
        carrier_defaults :consolidator => '1%'
        commission '0 5'

        # "выключаем отключение" комиссии
        defaults :corrector => nil, :consolidator => '3%'
        carrier 'SU'
        commission '0 5'
      end
    end

    it "should remove consolidator commission if agent's commission is percentage" do
      commission_class.for_carrier('FV').first.consolidator.should == Fx(0)
    end

    it "should not remove consolidator commission if agent's commission is lower or equal than 5" do
      commission_class.for_carrier('AB').first.consolidator.should == Fx('2%')
    end

    it "should remove consolidator commission if agent's commission is higher than 5" do
      commission_class.for_carrier('AF').first.consolidator.should == Fx(0)
    end

    it "should use changed value for consolidator's commission" do
      commission_class.for_carrier('HR').first.consolidator.should == Fx('1%')
    end

    it "should not be active when explicitly disabled" do
      commission_class.for_carrier('SU').first.consolidator.should == Fx('3%')
    end
  end
end

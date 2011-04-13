# encoding: utf-8
require 'spec_helper'

describe PricerForm do
  context "filled via ajax" do
    subject do
      described_class.new( attrs )
    end

    let :people_attrs do
      {"infants"=>"0", "adults"=>"1", "children"=>"0"}
    end

    context "when filled" do
      let :attrs do
        { "people_count" => people_attrs,
          "form_segments" => {
            "0" => {"from"=>"Москва", "date"=>"210411", "to"=>"Париж"},
            "1" => {"from"=>"Париж", "date"=>"280411", "to"=>"Москва"}}
        }
      end

      it do
        should be_valid
      end
    end

    context "when second row 'from' is not filled" do
      let :attrs do
        { "people_count" => people_attrs,
          "form_segments"=> {
            "0" => {"from"=>"Москва", "date"=>"210411", "to"=>"Париж"},
            "1" => {"from"=>"", "date"=>"280411", "to"=>"Москва"}}
        }
      end

      it do
        should be_valid
      end
    end
  end

  context "filled via api" do
    subject do
      described_class.simple( attrs )
    end

    context "when oneway" do
      let :attrs do
        { :from => 'MOW', :to => 'LON', :date1 => '091011' }
      end

      it { should be_valid }
      its(:rt) { should == false }
    end

    context "when twoway" do
      let :attrs do
        { :from => 'MOW', :to => 'LON', :date1 => '091011', :date2 => '092011' }
      end

      it { should be_valid }
      its(:rt) { should == true }
    end

    context "when requested business class" do
      let :attrs do
        { :from => 'MOW', :to => 'LON', :date1 => '091011', :cabin => 'C' }
      end

      it { should be_valid }
      its(:cabin) { should == 'C' }
    end
  end
end

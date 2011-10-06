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
          "segments" => {
            "0" => {"from"=>"Москва", "date"=>"210412", "to"=>"Париж"},
            "1" => {"from"=>"Париж", "date"=>"280412", "to"=>"Москва"}}
        }
      end

      it do
        should be_valid
      end
    end

    context "when second row 'from' is not filled" do
      let :attrs do
        { "people_count" => people_attrs,
          "segments"=> {
            "0" => {"from"=>"Москва", "date"=>"210412", "to"=>"Париж"},
            "1" => {"from"=>"",     "date"=>"280412", "to"=>"Москва"}}
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
        { :from => 'MOW', :to => 'LON', :date1 => '091011', :date2 => '091111' }
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

    context "when got empty people values" do
      let :attrs do
        { :from => 'MOW', :to => 'LON', :date1 => '091011', :cabin => 'C', :adults => nil, :children => nil, :infants => nil, :seated_infants => nil }
      end

      it { should be_valid }
      its(:real_people_count) { should == {:children=>0, :adults=>1, :infants=>0} }
    end
  end

  describe "#simple" do
     it "should raise ArgumentError for parameters that do not exist" do
      args = {
              :from => 'MOW',
              :to => 'LON',
              :date1 => '091011',
              :childrens => 1,
              :cabin => 'C'}

      expect{ PricerForm.simple(args) }.to raise_error(ArgumentError, 'Unknown parameter(s) - "childrens"')
     end
    it "should raise ArgumentError if from and to are not iatas" do
      args = {
              :from => 'Зимбабве',
              :to => 'LON',
              :date1 => '091011',
              :cabin => 'C'}
       expect{ PricerForm.simple(args) }.to raise_error(IataStash::NotFound,"Couldn't find Airport with IATA 'Зимбабве'")
    end
    it "should raise ArgumentError if from, to or data1 are not there" do
      args = {
              :date1 => '091011',
              :cabin => 'C'}
       expect{ PricerForm.simple(args) }.to raise_error(ArgumentError, 'Lack of required parameter(s)  - "from, to"')
    end
  end
end


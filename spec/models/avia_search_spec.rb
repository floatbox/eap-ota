# encoding: utf-8
require 'spec_helper'

describe AviaSearch do

  let(:yy) {1.year.from_now.strftime('%y')}

  context "filled via ajax" do
    subject do
      described_class.from_js( attrs )
    end

    let :people_attrs do
      {"infants"=>"0", "adults"=>"1", "children"=>"0"}
    end

    context "when filled with segment hash" do
      let :attrs do
        {
          :people_count => people_attrs,
          :segments => {
            "0" => {:from => "MOW", :date => "2104#{yy}", :to => "PAR"},
            "1" => {:from =>"PAR", :date =>"2804#{yy}", :to =>"MOW"}
          }
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

    context "when filled with AviaSearchSegment classes" do
      let :attrs do
        {
          :people_count => people_attrs,
          :segments => [
            ::AviaSearchSegment.new(from: 'MOW', to: 'PAR', date: "2104#{yy}"),
            ::AviaSearchSegment.new(from: 'PAR', to: 'MOW', date: "2804#{yy}")
          ]
        }
      end
    end

    context "when oneway" do
      let :attrs do
        { :from => 'MOW', :to => 'LON', :date1 => "0910#{yy}" }
      end

      it { should be_valid }
      its(:rt) { should == false }
    end

    context "when twoway" do
      let :attrs do
        { :from => 'MOW', :to => 'LON', :date1 => "0910#{yy}", :date2 => "0911#{yy}" }
      end

      it { should be_valid }
      its(:rt) { should == true }
    end

    context "when requested business class" do
      let :attrs do
        { :from => 'MOW', :to => 'LON', :date1 => "0910#{yy}", :cabin => 'C' }
      end

      it { should be_valid }
      its(:cabin) { should == 'C' }
    end

    context "when got empty people values" do
      let :attrs do
        { :from => 'MOW', :to => 'LON', :date1 => "0910#{yy}", :cabin => 'C', :adults => nil, :children => nil, :infants => nil, :seated_infants => nil }
      end

      it { should be_valid }
      its(:tariffied) { should == {:children=>0, :adults=>1, :infants=>0} }
    end
  end

  describe "#simple" do
     it "should raise ArgumentError for parameters that do not exist" do
      args = {
              :from => 'MOW',
              :to => 'LON',
              :date1 => "0910#{yy}",
              :childrens => 1,
              :cabin => 'C'}

      expect{ AviaSearch.simple(args) }.to raise_error(ArgumentError, 'Unknown parameter(s) - "childrens"')
     end
    it "should raise ArgumentError if from and to are not iatas" do
      args = {
              :from => 'Зимбабве',
              :to => 'LON',
              :date1 => "0910#{yy}",
              :cabin => 'C'}
       expect{ AviaSearch.simple(args) }.to raise_error(CodeStash::NotFound,"Couldn't find Airport with code 'Зимбабве'")
    end
    it "should raise ArgumentError if from, to or data1 are not there" do
      args = {
              :date1 => "0910#{yy}",
              :cabin => 'C'}
       expect{ AviaSearch.simple(args) }.to raise_error(ArgumentError, 'Lack of required parameter(s)  - "from, to"')
    end
  end
end

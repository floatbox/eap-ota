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

    context "when filled with incomplete data" do

      let :attrs do
        { people_count: people_attrs }
      end

      it do
        should_not be_valid
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
        { :from => 'MOW', :to => 'LON', :date1 => "0910#{yy}", :cabin => 'C', :adults => nil, :children => nil, :infants => nil }
      end

      it { should be_valid }
      its(:tariffied) { should == {:children=>0, :adults=>1, :infants=>0} }
    end

    context "when got empty people values" do
      let :attrs do
        { :from => 'MOW', :to => 'LON', :date1 => "0910#{yy}", :cabin => 'C', :adults => nil, :children => nil, :infants => nil }
      end

      it { should be_valid }
      its(:tariffied) { should == {:children=>0, :adults=>1, :infants=>0} }
    end

    context "when got multisegment format" do
      let :attrs do
        { :from1 => 'MOW', :to1 => 'LON', :date1 => "0910#{yy}",
          :from2 => 'LON', :to2 => 'PAR', :date2 => "1010#{yy}",
          :from3 => 'PAR', :to3 => 'LED', :date3 => "1110#{yy}",
          :from4 => 'LED', :to4 => 'ROV', :date4 => "1210#{yy}",
          :from5 => 'ROV', :to5 => 'ROM', :date5 => "1210#{yy}",
          :from6 => 'ROM', :to6 => 'MOW', :date6 => "1210#{yy}",
          :cabin => 'C', :adults => "1" }
      end

      it { should be_valid }
      it { should have(6).segments }
    end

    context "when got partial multisegment format" do
      let :attrs do
        { :from1 => 'MOW',
          :to1 => 'LON', :date1 => "0910#{yy}",
          :to2 => 'PAR', :date2 => "1010#{yy}",
          :to3 => 'LED', :date3 => "1110#{yy}",
          :to4 => 'ROV', :date4 => "1210#{yy}",
          :to5 => 'ROM', :date5 => "1310#{yy}",
          :to6 => 'MOW', :date6 => "1410#{yy}",
          :cabin => 'C', :adults => "1" }
      end

      it { should be_valid }
      it { should have(6).segments }
      its('segments.last.from') {should == City['ROM']}
      its('segments.last.to') {should == City['MOW']}
      its('segments.last.date') {should == Date.new(Date.today.year+1, 10, 14)}
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

    pending "should raise ArgumentError if from and to are not iatas" do
      args = {
              :from => 'Зимбабве',
              :to => 'LON',
              :date1 => "0910#{yy}",
              :cabin => 'C'}
       expect{ AviaSearch.simple(args) }.to raise_error(ArgumentError)
    end

    pending "should raise ArgumentError if from and/or to are new iatas" do
      unknown_iata = 'BBQ'
      args = {
              :from => 'LON',
              :to => unknown_iata,
              :date1 => "0910#{yy}",
              :cabin => 'C'}
       expect{ AviaSearch.simple(args) }.to raise_error(ArgumentError)
       Airport.lost.where(iata: unknown_iata).should_not == []
    end

    it "should raise ArgumentError if from, to or data1 are not there" do
      args = {
              :date1 => "0910#{yy}",
              :cabin => 'C'}
       expect{ AviaSearch.simple(args) }.to raise_error(ArgumentError, 'Lack of required parameter(s)  - "from1, to1"')
    end
  end
end


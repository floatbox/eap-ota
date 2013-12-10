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

  context "people count" do
    subject do
      described_class.simple attrs
    end

    let :base_attrs do
      { :from => 'MOW', :to => 'LON', :date1 => "20#{yy}-10-09" }
    end

    context "1 adult only" do
      let :attrs do
        base_attrs.dup.merge adults: 1, children: 0, infants: 0
      end

      it {should be_valid}
    end

    context "no passengers" do
      let :attrs do
        base_attrs.dup.merge adults: 0, children: 0, infants: 0
      end

      it {should_not be_valid}
    end

    context "7 adults — just one too many" do
      let :attrs do
        base_attrs.dup.merge adults: 7, children: 0, infants: 0
      end

      it {should_not be_valid}
    end

    context "unaccompanied infant" do
      let :attrs do
        base_attrs.dup.merge adults: 1, children: 0, infants: 2
      end

      xit {should_not be_valid}
    end
  end

  context "filled via api" do
    subject do
      described_class.simple( attrs )
    end

    context "when oneway" do
      let :attrs do
        { :from => 'MOW', :to => 'LON', :date1 => "20#{yy}-10-09" }
      end

      it { should be_valid }
      its(:rt) { should == false }
    end

    context "when twoway" do
      let :attrs do
        { :from => 'MOW', :to => 'LON', :date1 => "20#{yy}-10-09", :date2 => "20#{yy}-11-09" }
      end

      it { should be_valid }
      its(:rt) { should == true }
    end

    context "when requested business class" do
      let :attrs do
        { :from => 'MOW', :to => 'LON', :date1 => "20#{yy}-10-09", :cabin => 'C' }
      end

      it { should be_valid }
      its(:cabin) { should == 'C' }
    end

    context "when got empty people values" do
      let :attrs do
        { :from => 'MOW', :to => 'LON', :date1 => "20#{yy}-10-09", :cabin => 'C', :adults => nil, :children => nil, :infants => nil }
      end

      it { should be_valid }
      its(:tariffied) { should == {:children=>0, :adults=>1, :infants=>0} }
    end

    context "when got multisegment format" do
      let :attrs do
        { :from1 => 'MOW', :to1 => 'LON', :date1 => "20#{yy}-10-09",
          :from2 => 'LON', :to2 => 'PAR', :date2 => "20#{yy}-10-10",
          :from3 => 'PAR', :to3 => 'LED', :date3 => "20#{yy}-10-11",
          :from4 => 'LED', :to4 => 'ROV', :date4 => "20#{yy}-10-12",
          :from5 => 'ROV', :to5 => 'ROM', :date5 => "20#{yy}-10-13",
          :from6 => 'ROM', :to6 => 'MOW', :date6 => "20#{yy}-10-14",
          :cabin => 'C', :adults => "1" }
      end

      it { should be_valid }
      it { should have(6).segments }
    end

    context "when got partial multisegment format" do
      let :attrs do
        { :from1 => 'MOW',
          :to1 => 'LON', :date1 => "20#{yy}-10-09",
          :to2 => 'PAR', :date2 => "20#{yy}-10-10",
          :to3 => 'LED', :date3 => "20#{yy}-10-11",
          :to4 => 'ROV', :date4 => "20#{yy}-10-12",
          :to5 => 'ROM', :date5 => "20#{yy}-10-13",
          :to6 => 'MOW', :date6 => "20#{yy}-10-14",
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
    pending "should raise ArgumentError for parameters that do not exist" do
      args = {
              :from => 'MOW',
              :to => 'LON',
              :date1 => "20#{yy}-10-09",
              :childrens => 1,
              :cabin => 'C'}

      expect{ AviaSearch.simple(args) }.to raise_error(ArgumentError, 'Unknown parameter(s) - "childrens"')
    end

    pending "should raise ArgumentError if from and to are not iatas" do
      args = {
              :from => 'Зимбабве',
              :to => 'LON',
              :date1 => "20#{yy}-10-09",
              :cabin => 'C'}
       expect{ AviaSearch.simple(args) }.to raise_error(ArgumentError)
    end

    pending "should raise ArgumentError if from and/or to are new iatas" do
      unknown_iata = 'BBQ'
      args = {
              :from => 'LON',
              :to => unknown_iata,
              :date1 => "20#{yy}-10-09",
              :cabin => 'C'}
       expect{ AviaSearch.simple(args) }.to raise_error(ArgumentError)
       Airport.lost.where(iata: unknown_iata).should_not == []
    end

    it "should raise ArgumentError if from, to or data1 are not there" do
      args = {
              :date1 => "20#{yy}-10-09",
              :cabin => 'C'}
       expect{ AviaSearch.simple(args) }.to raise_error(ArgumentError, 'Lack of required parameter(s)  - "from1, to1"')
    end
  end
end


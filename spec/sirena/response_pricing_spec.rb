# encoding: utf-8
require 'spec_helper'

describe Sirena::Response::Pricing do

  let(:response) { described_class.new( File.read(xml) ) }

  context 'with one adult, two way' do

    let(:xml) { 'spec/sirena/xml/pricing_two_way.xml' }
    subject {response}

    it { should be_success }
    it { should have(4).recommendations }

    context "first recommendation" do
      subject {response.recommendations.first}

      its(:sirena_blank_count) {should == 1}
      its(:cabins) {should == ['Y', 'Y']}

      context "first segment" do
        subject { response.recommendations.first.segments.first }
        its(:total_duration) {should == 75}
      end

      context "first flight" do
        subject { response.recommendations.first.flights.first }
        its(:duration) {should == 75}
      end
    end
  end

  context 'ITK-AER' do

    let(:xml) { 'spec/sirena/xml/pricing_ITK_AER.xml' }
    subject {response}

    it { should be_success }
    it { should have(1).recommendations }

    context "first recommendation" do
      subject {response.recommendations.first}
      its(:sirena_blank_count) {should == 4}
      its(:cabins) {should == ['Y', 'Y', 'Y', 'Y']}

      context "first segment" do
        subject { response.recommendations.first.segments.first }
        its(:total_duration) {should == 675}
      end

      context "first flight" do
        subject { response.recommendations.first.flights.first }
        its(:duration) {should == 365}
      end
    end
  end
end


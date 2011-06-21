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
      its(:booking_classes) {should == ['Y', 'Y']}

      context "first segment" do
        subject { response.recommendations.first.segments.first }
        its(:total_duration) {should == 75}
      end

      context "first flight" do
        subject { response.recommendations.first.flights.first }
        its(:duration) {should == 75}
      end
    end

    context "second recommendation" do
      subject {response.recommendations[1]}

      its(:sirena_blank_count) {should == 1}
      its(:cabins) {should == ['Y', 'Y']}
      its(:booking_classes) {should == ['M', 'Y']}
    end
  end

  context 'ITK-AER' do

    let(:xml) { 'spec/sirena/xml/pricing_ITK_AER.xml' }
    subject {response}

    it { should be_success }
    it { should have(1).recommendations }

    context "first recommendation" do
      subject {response.recommendations.first}
      it {should have(2).variants}
      its(:sirena_blank_count) {should == 4}
      its(:cabins) {should == ['Y', 'Y', 'Y', 'Y']}
      its(:booking_classes) {should == ['H', 'H', 'H', 'H']}

      context "first segment" do
        subject { response.recommendations.first.variants.first.segments[0] }
        its(:total_duration) {should == 675}
      end

      context "second segment" do
        subject { response.recommendations.first.variants.first.segments[1] }
        its(:total_duration) {should == 615}
      end

      context "first flight" do
        subject { response.recommendations.first.variants.first.flights.first }
        its(:duration) {should == 365}
      end
    end
  end
end


# encoding: utf-8
require 'spec_helper'

describe Sirena::Response::Pricing do

  subject { described_class.new( File.read(response) ) }

  describe 'with one adult, two way' do

    let(:response) { 'spec/sirena/xml/pricing_two_way.xml' }

    it { should be_success }
    it { should have(4).recommendations }
    specify { subject.recommendations.first.sirena_blank_count.should == 1 }
  end

end

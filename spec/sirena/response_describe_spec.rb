# encoding: utf-8
require 'spec_helper'

describe Sirena::Response::Describe do

  subject { described_class.new( File.read(response) ) }

  describe 'with one adult, unpaid' do

    let(:response) { 'spec/sirena/xml/describe_fail.xml' }

    it { should_not be_success }
    its(:error) { should == "Неправильный формат элемента 'data'" }
  end
end


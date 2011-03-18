# encoding: utf-8
require 'spec_helper'

describe Sirena::Response::Order do
  describe 'with one adult, unpaid' do

    subject {
      body = File.read('spec/sirena/xml/describe_fail.xml')
      Sirena::Response::Order.new(body)
    }

    it { should_not be_success }
    its(:error) { should == "Неправильный формат элемента 'data'" }
  end
end


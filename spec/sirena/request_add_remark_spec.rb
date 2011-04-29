# encoding: utf-8
require 'spec_helper'

describe Sirena::Request::AddRemark do

  describe 'common case' do

    subject { described_class.new( 'ВЫПР23К', 'ИВАНОВ', 'M 2567 33%' ) }

    it "renders ok" do
      expect { subject.render }.to_not raise_error
    end

  end
end


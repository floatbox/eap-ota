# encoding: utf-8
require 'spec_helper'

describe Sirena::Response::GetItinReceipts do
  describe 'with one adult' do

    subject {
      body = File.read('spec/sirena/xml/get_itin_receipts_successful.xml')
      Sirena::Response::GetItinReceipts.new(body)
    }

    it { should be_success }
    its(:pdf) { should match(/^%PDF-1.3/) }
    specify { subject.pdf.size.should == 42751 }
  end
end

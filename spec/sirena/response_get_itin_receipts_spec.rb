# encoding: utf-8
require 'spec_helper'

describe Sirena::Response::GetItinReceipts do

  subject { described_class.new( File.read(response) ) }

  describe 'with one adult' do

    let(:response) { 'spec/sirena/xml/get_itin_receipts_successful.xml' }

    it { should be_success }
    its(:pdf) { should match(/^%PDF-1.3/) }
    specify { subject.pdf.size.should == 42751 }
  end
end

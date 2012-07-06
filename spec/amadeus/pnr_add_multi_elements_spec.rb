# encoding: utf-8
require 'spec_helper'

describe Amadeus::Response::PNRAddMultiElements do

  context 'with srfoid error' do

    let_once! :response do
      amadeus_response('spec/amadeus/xml/PNR_AddMultiElements_with_bad_srfoid.xml')
    end

    subject {response}

    its(:srfoid_errors) {should == ['SRFOID error: UN: INVALID TEXT DATA']}
    its(:success?) {should be_false}
    its(:error_text) {should == 'SRFOID error: UN: INVALID TEXT DATA'}
  end

end


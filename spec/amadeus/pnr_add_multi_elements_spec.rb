# encoding: utf-8
require 'spec_helper'

describe Amadeus::Response::PNRAddMultiElements, :amadeus do

  context 'with srfoid error' do

    let_once! :response do
      amadeus_response('spec/amadeus/xml/PNR_AddMultiElements_with_bad_srfoid.xml')
    end

    subject {response}

    its(:srfoid_errors) {should == ['SRFOID error: UN: INVALID TEXT DATA']}
    its(:success?) {should be_false}
    its(:error_text) {should == 'SRFOID error: UN: INVALID TEXT DATA'}
  end

  context 'with name error' do
    let_once! :response do
      amadeus_response('spec/amadeus/xml/PNR_AddMultiElements.long_name.xml')
    end

    subject {response}

    its(:srfoid_errors) {should == []}
    its(:success?) {should be_false}
    its(:error_text) {should == 'Name error: ITEM TOO LONG / NOT ENTERED /'}
  end

end


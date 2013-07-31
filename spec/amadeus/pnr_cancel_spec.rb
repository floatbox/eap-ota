# encoding: utf-8
require 'spec_helper'

describe Amadeus::Response::PNRCancel, amadeus: true  do

  describe 'error_message' do

    let_once! :response do
      amadeus_response('spec/amadeus/xml/PNR_Cancel_failed.xml')
    end

    subject {response.error_message}
    it {should == 'SIMULTANEOUS CHANGES TO PNR - USE WRA/RT TO PRINT OR IGNORE'}


  end

end


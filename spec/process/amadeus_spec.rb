# encoding: utf-8
require 'spec_helper'

describe Amadeus::Service do
  use_vcr_cassette 'amadeus_cmd', :record => :new_episodes

  it "should be working" do
    Amadeus::Service.cmd('help').should =~ /HELP/
  end
end


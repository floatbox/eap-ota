# encoding: utf-8
require 'spec_helper'

describe Amadeus::Service do
  use_vcr_cassette 'foo', :record => :new_episodes

  it "should be ok" do
    Amadeus::Service.cmd('help').should =~ /HELP/
  end
end


# encoding: utf-8
require 'spec_helper'

describe Amadeus::Service do
  use_vcr_cassette 'amadeus_cmd', :record => :new_episodes

  it "should require session" do
    expect { Amadeus::Service.cmd('help') }.to raise_error
  end

  it "should be working" do
    Amadeus.booking.cmd('help').should =~ /HELP/
  end
end


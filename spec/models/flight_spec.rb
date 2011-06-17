# encoding: utf-8
require 'spec_helper'

describe Flight do
  it "should deserialize cyrillics" do
    expect { Flight.from_flight_code('ЮТ369ВНКПЛК060711') }.to_not raise_error
  end
end

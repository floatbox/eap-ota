# encoding: utf-8
require 'spec_helper'

describe Recommendation do
  it "should deserialize cyrillics" do
    expect { Recommendation.deserialize('sirena.ЮТ.ЦС.YY..ЮТ369ВНКПЛК060711.ЮТ370ПЛКВНК270711') }.to_not raise_error
  end
end

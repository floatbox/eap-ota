#encoding: utf-8
require 'spec_helper'

describe Monitoring::RiemannConnection::Client do

  let(:rclient) { mock(Riemann::Client).stub(:<<, nil) }
  let(:event_hash) do
    {
      :service => 'test my value',
      :metric => 1.0
    }
  end

  before do
  	Monitoring::RiemannConnection::Client.stub(:connection, rclient)
    @riemann = Monitoring::RiemannConnection::Client
  end

  describe ".send_event" do
    it "not raises error"
  end

  describe ".send_meter" do
    it "not raises error"
  end

  describe ".send_histogram" do
    it "not raises error"
  end

  describe ".send_gauge" do
    it "not raises error"
  end

  describe ".send_occurrence" do
    it "not raises error"
  end
end
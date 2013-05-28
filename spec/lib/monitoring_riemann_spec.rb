#encoding: utf-8
require 'spec_helper'

describe Monitoring::RiemannConnection do

  let(:rclient) { mock(Riemann::Client).stub(:<<, nil) }
  let(:event_hash) do
    {
      :tags => ['graph'],
      :service => 'test my value',
      :metric => 1.0
    }
  end

  before do
  	Monitoring::RiemannConnection.stub(:connection, rclient)
    @riemann = Monitoring::RiemannConnection
  end

  describe ".send_event" do
    it "not raises error" do
      expect {@riemann.send_event(event_hash)}.to_not raise_error
    end
  end

  describe ".fix_env_tags" do

    it "adds environment tag if no environment tag is given" do
      expect(@riemann.send(:fix_env_tag, event_hash)[:tags]).to match_array ['graph', 'test']
    end

    it "adds environment tag if tags are not given at all" do
	  event_hash[:tags] = []
	  expect(@riemann.send(:fix_env_tag, event_hash)[:tags]).to match_array ['test']
    end

	it "adds environment tag if tags are absent from event_hash" do
	  event_hash[:tags] = nil
	  expect(@riemann.send(:fix_env_tag, event_hash)[:tags]).to match_array ['test']
    end

    it "places just one tag if several is given" do
      event_hash[:tags] << 'staging'
      expect(@riemann.send(:fix_env_tag, event_hash)[:tags]).to match_array ['graph', 'test']
    end

  end

end
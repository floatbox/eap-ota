require 'spec_helper'

describe Amadeus::Service do

  it "should be ok" do
    VCR.use_cassette('foo', :record => :new_episodes) do
      Amadeus::Service.cmd('help').should =~ /HELP/
    end
  end
end


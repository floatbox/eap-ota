# encoding: utf-8
require 'spec_helper'

# FIXME по-stub-ить все эти внешние зависимости, что ли
describe IataStash do

  it "should not raise when searching for IATA" do
    expect { Airport['DME'] }.to_not raise_error(IataStash::NotFound)
  end

  it "should not raise when searching for russian code" do
    expect { Airport['ДМД'] }.to_not raise_error(IataStash::NotFound)
  end

  it "should raise an exception trying to find unknown iata" do
    expect { Airport['FFFF'] }.to raise_error(IataStash::NotFound)
  end

  it "exception trying to find unknown iata" do
    (Airport['FFFF'] rescue $!.message).should == "Couldn't find Airport with IATA 'FFFF'"
  end
end


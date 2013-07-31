# encoding: utf-8
require 'spec_helper'

# FIXME по-stub-ить все эти внешние зависимости, что ли
describe CodeStash do

  it "should not raise when searching for IATA" do
    expect { Airport['DME'] }.to_not raise_error(CodeStash::NotFound)
  end

  it "should not raise when searching for russian code" do
    pending "sirena is disabled for now"
    Airport['ДМД'].should_not raise_error(CodeStash::NotFound)
  end

  it "should raise an exception trying to find unknown airport by iata" do
    Airport['ZZZ'].should raise_error(CodeStash::NotFound)
    Airport.fetch_by_code('ZZZ').should raise_error(CodeStash::NotFound)
  end

  it "should raise an exception trying to find unknown carrier by iata" do
    Carrier['ZZ'].should raise_error(CodeStash::NotFound)
    Carrier.fetch_by_code('ZZ').should raise_error(CodeStash::NotFound)
  end

  it "should raise an exception trying to find unknown city by iata" do
    City['ZZZ'].should raise_error(CodeStash::NotFound)
    City.fetch_by_code('ZZZ').to_a.should raise_error(CodeStash::NotFound)
  end

  it "should raise an exception trying to find unknown country iata" do
    Country['ZZ'].should raise_error(CodeStash::NotFound)
    Country.fetch_by_code('ZZ').should raise_error(CodeStash::NotFound) 
  end

  it "exception trying to find unknown iata" do
    (Airport['FFFF'] rescue $!.message).should == "Couldn't find Airport with code 'FFFF'"
  end

  it "should not raise an exception then searching for unknown airplane" do
    Airplane['BBQ'].should_not raise_error(CodeStash::NotFound)
    Airplane.where(iata: 'BBQ', auto_save: true).should_not be_nil
  end

end


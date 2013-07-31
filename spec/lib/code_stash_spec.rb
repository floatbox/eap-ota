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

  context '[] on Models' do

    pending context 'with empty code' do
      it "Airport should raise error if called with an empty code" do
        expect { Airport[nil] }.to raise_error(CodeStash::NotFound)
      end

      it "City should raise error if called with an empty code" do
        expect { City[nil] }.to raise_error(CodeStash::NotFound)
      end

      it "Carrier should raise error if called with an empty code" do
        expect { Carrier[nil] }.to raise_error(CodeStash::NotFound)
      end

      it "Country should raise error if called with an empty code" do
        expect { Country[nil] }.to raise_error(CodeStash::NotFound)
      end
    end

    context 'with unknown code' do
      it "should raise an exception trying to find unknown airport by iata" do
        expect { Airport['ZZZ'] }.to raise_error(CodeStash::NotFound)
      end

      it "should raise an exception trying to find unknown carrier by iata" do
        expect { Carrier['ZZ'] }.to raise_error(CodeStash::NotFound)
      end

      it "should raise an exception trying to find unknown city by iata" do
        expect { City['ZZZ'] }.should raise_error(CodeStash::NotFound)
      end

      it "should raise an exception trying to find unknown country iata" do
        expect { Country['ZZ'] }.to raise_error(CodeStash::NotFound)
      end
    end
  end

  context 'fetch_by_code on Models' do
    specify { Airport.fetch_by_code(nil).should be_nil }
    specify { City.   fetch_by_code(nil).should be_nil }
    specify { Carrier.fetch_by_code(nil).should be_nil }
    # Косово в базе c alpha2 = nil
    pending { specify { Country.fetch_by_code(nil).should be_nil } }
  end

  it "exception trying to find unknown iata" do
    (Airport['FFFF'] rescue $!.message).should == "Couldn't find Airport with code 'FFFF'"
  end

  pending it "should not raise an exception then searching for unknown airplane" do
    expect { Airplane['BBQ'] }.to_not raise_error(CodeStash::NotFound)
    Airplane.where(iata: 'BBQ', auto_save: true).should_not be_nil
  end

end


# encoding: utf-8
require 'spec_helper'

describe Strategy::Amadeus do
  let (:amadeus) { double(Amadeus::Service) }

  before do
    # safeguard
    Amadeus.stub(:booking).and_yield(amadeus).and_return(amadeus)
    Amadeus.stub(:ticketing).and_yield(amadeus).and_return(amadeus)
  end

  it "not yet implements #void" do
    expect { described_class.new.void }.to raise_error(NotImplementedError)
  end

  it "not yet implements #ticket" do
    expect { described_class.new.ticket }.to raise_error(NotImplementedError)
  end

  pending "#check_price_and_availability"
  pending "#create_booking"
  pending "#cancel"
  pending "#void"
  pending "#delayed_ticketing?"
  pending "#ticket"
  pending "#raw_pnr"
  pending "#raw_ticket"
end

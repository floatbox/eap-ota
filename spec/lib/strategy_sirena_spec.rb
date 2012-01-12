# encoding: utf-8
require 'spec_helper'

describe Strategy::Sirena do
  let (:sirena) { double(Sirena::Service) }

  # safeguard
  before do
    Sirena::Service.stub(:new).and_return(sirena)
  end

  it "not yet implements #raw_ticket" do
    expect { described_class.new.raw_ticket }.to raise_error(NotImplementedError)
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

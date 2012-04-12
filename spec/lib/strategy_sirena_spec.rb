# encoding: utf-8
require 'spec_helper'

describe Strategy::Sirena do
  let (:sirena) { mock(Sirena::Service) }

  # safeguard
  before do
    Sirena::Service.stub(:new).and_return(sirena)
  end

  it "not yet implements #raw_ticket" do
    expect { described_class.new.raw_ticket }.to raise_error(NotImplementedError)
  end

  describe "delayed_ticketing?" do
    it "should not autmatically ticket offline bookings" do
      subject.order = mock(Order, :offline_booking? => true)
      subject.delayed_ticketing?.should be_true
    end
    it "should ticket normal bookings automatically" do
      subject.order = mock(Order, :offline_booking? => false)
      subject.delayed_ticketing?.should be_false
    end
  end

  pending "#check_price_and_availability"
  pending "#create_booking"
  pending "#cancel"
  pending "#void"
  pending "#ticket"
  pending "#raw_pnr"
  pending "#raw_ticket"
  pending "#flight_from_gds_code"
end

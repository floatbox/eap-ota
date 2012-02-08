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

  describe "#get_tickets" do
    it 'returns correct price_fare for ticket with fare upgrade' do
      pnr_resp = mock('PNRRetrieve')
      tickets_hash = {[1, 'a'] => {:number => '123', :code => '456', :price_fare => 1000, :price_tax => 500}}
      exchanged_tickets = {[1, 'a'] => {:number => '234', :code => '456', :status => 'exchanged'}}
      tst_resp = mock('TicketDisplayTST')
      pnr_resp.stub_chain(:tickets, :deep_merge).and_return(tickets_hash)
      pnr_resp.should_receive(:exchanged_tickets).and_return(exchanged_tickets)
      amadeus = mock('Amadeus')
      amadeus.stub(:pnr_retrieve).and_return(pnr_resp)
      amadeus.stub(:pnr_ignore)
      amadeus.stub_chain(:ticket_display_tst, :prices_with_refs).and_return({})
      Amadeus.should_receive(:booking).once.and_yield(amadeus)
      old_ticket = mock('Ticket', :price_fare => 800, :code => '456', :number => '234', :id => 10)
      Ticket.stub_chain(:where, :first).and_return(old_ticket)
      Ticket.stub_chain(:office_ids, :include?).and_return(true)
      result_tickets = Strategy::Amadeus.new(:order => mock('Order', :pnr_number => '', :commission_subagent => 0)).get_tickets
      result_tickets.map{|th| th[:price_fare]}.compact.first.should == 200
    end
  end

  describe "#flight_from_gds_code" do
    let (:flight) { double(Flight) }
    let (:stubbed_air_flight_info) {
      double("air_flight_info").tap {|air_flight_info|
        air_flight_info.stub(:flight).and_return(flight)
      }
    }

    it "should call air_flight_info with correct params" do
      code = '3  BT 419 Z 01AUG 4 DMERIX HK1  1505 1600  01AUG  E  BT/22BFU3'
      Amadeus::Service.should_receive(:air_flight_info)\
        .with(:date => Date.new(2012, 8, 1), :number => '419', :carrier => 'BT', :departure_iata => 'DME', :arrival_iata => 'RIX')\
        .and_return(stubbed_air_flight_info)

      Strategy::Amadeus.new.flight_from_gds_code(code).should == flight
    end
  end

end

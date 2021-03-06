# encoding: utf-8
require 'spec_helper'

describe Amadeus::Strategy do
  let (:amadeus) { mock(Amadeus::Service, release: nil, destroy: nil) }

  before do
    # "разогревает" handsoap настоящим инстансом Amadeus::Service
    # перед тем, как заstubить фальшивкой. нужно для parse_string
    Amadeus::Service.instance
    Amadeus::Service.stub( new: amadeus)
  end

  it "not yet implements #void" do
    expect { described_class.new.void }.to raise_error(NotImplementedError)
  end

  pending "#ticket"

  describe "#get_tickets" do
    pending "with tst_resp"
    pending "without tst_resp"
  end

  pending "#check_price_and_availability"
  pending "#create_booking"
  pending "#cancel"
  pending "#raw_pnr"

  # FIXME ясностью не блещет
  describe "#raw_ticket" do
    let(:ticket) { mock(Ticket, office_id: office, first_number_with_code: '123-23456789') }
    subject { Amadeus::Strategy.new(:ticket => ticket) }

    context "on whitelisted office_id" do
      before do
        Amadeus::Service.should_receive(:new).with( hash_including(:office => office) ) \
          .and_return(amadeus)
        amadeus.stub(:ticket_raw => expected_result)
      end
      let(:expected_result) {'raw tickets result'}

      context "MOWR2233B" do
        let(:office) {'MOWR2233B'}
        its(:raw_ticket) {should == expected_result}
      end
      context "MOWR228FA" do
        let(:office) {'MOWR228FA'}
        its(:raw_ticket) {should == expected_result}
      end
    end

    context "on other office_ids" do
      context "FLL1S212V" do
        let(:office) {"FLL1S212V"}
        its(:raw_ticket) {should include("not supported")}
      end
    end
  end

  its(:delayed_ticketing?) {should be_true}

  describe "#booking_attributes" do

    before(:each) do
      amadeus.stub(
        pnr_retrieve:
          amadeus_response('spec/amadeus/xml/PNR_Retrieve_with_ticket.xml'),
        ticket_display_tst:
          amadeus_response('spec/amadeus/xml/Ticket_DisplayTST_with_ticket.xml'),
        pnr_ignore: nil
      )
    end

    subject do
      Amadeus::Strategy.new(:order => build(:order)).booking_attributes
    end

    it {should include(:blank_count => 1)}
    it {should include(:commission_carrier => "SU")}
    it {should include(:commission_agent => '7%')}
    it {should include(:departure_date => Date.new(2011, 9, 8))}
    it {should include(:price_fare => 1400)}
    it {should include(:price_tax => 1281)}

  end

  describe "#recommendation_from_booking" do

    before(:each) do
      # лень сооружать подходящий flight_info, делаем вид,
      # что амадеус про конкретный вылет все забыл
      air_flight_info_result = mock(:air_flight_info_result, success?: false)
      amadeus.stub(
        pnr_retrieve:
          amadeus_response('spec/amadeus/xml/PNR_Retrieve_with_ticket.xml'),
        ticket_display_tst:
          amadeus_response('spec/amadeus/xml/Ticket_DisplayTST_with_ticket.xml'),
        air_flight_info: air_flight_info_result,
        pnr_ignore: nil
      )
    end

    subject :recommendation do
      Amadeus::Strategy.new(:order => build(:order)).recommendation_from_booking
    end

    it 'is not nil' do
      expect(recommendation).to_not be_nil
    end

    it 'got a valid value of validating_carrier_iata' do
      expect(recommendation.validating_carrier_iata).to eq 'SU'
    end

    it 'got a valid value of price_fare' do
      expect(recommendation.price_fare).to eq 1400
    end

    it 'got a valid value of price_tax' do
      expect(recommendation.price_tax).to eq 1281
    end

    it 'got a valid values of flight codes' do
      expect( recommendation.flights.first.flight_code ).to eq 'SU788MRVSVO080911'
    end

  end

  describe "#flight_from_gds_code" do
    let (:flight) { mock(Flight) }

    it "should call air_flight_info with correct params" do
      code = '3  BT 419 Z 01AUG 4 DMERIX HK1  1505 1600  01AUG  E  BT/22BFU3'
      # FIXME сломается каждого первого августа!
      flight_date = Date.today.month < 8 ? Date.new(Date.today.year, 8, 1) : Date.new(Date.today.year + 1, 8, 1)
      amadeus.should_receive(:air_flight_info)\
        .with(:date => flight_date, :number => '419', :carrier => 'BT', :departure_iata => 'DME', :arrival_iata => 'RIX')\
        .and_return( mock(Amadeus::Response::AirFlightInfo, flight: flight) )

      Amadeus::Strategy.new.flight_from_gds_code(code).should == flight
    end
  end

end

require 'spec_helper'

describe Order do

  describe "#tickets.spawn" do
    it 'should raise exception if number is blank' do
      o = Order.new
      expect { o.tickets.spawn("") }.to raise_error
    end
  end

  describe '#load_tickets' do

    before(:each) do
      @order = Order.new(:source => 'amadeus', :commission_subagent => '1%', :pnr_number => '123456')
      @amadeus = mock('Amadeus')

      body = File.read('spec/amadeus/xml/PNR_Retrieve_with_ticket.xml')
      doc = Amadeus::Service.parse_string(body)
      @amadeus.stub(:pnr_retrieve).and_return(Amadeus::Response::PNRRetrieve.new(doc))


      body = File.read('spec/amadeus/xml/Ticket_DisplayTST_with_ticket.xml')
      doc = Amadeus::Service.parse_string(body)
      @amadeus.stub(:ticket_display_tst).and_return(Amadeus::Response::TicketDisplayTST.new(doc))
      @amadeus.stub(:pnr_ignore)
    end

    it 'loads tickets correctly from amadeus' do
      Amadeus.should_receive(:booking).once.and_yield(@amadeus)
      @order.stub_chain(:tickets, :where, :every, :update_attribute)
      @order.stub_chain(:tickets, :reload)
      ticket = stub_model(Ticket)
      @order.stub_chain(:tickets, :spawn).and_return(ticket)
      ticket.should_receive(:update_attributes).with(hash_including(
        :code => "555",
        :number => "2962867063",
        :last_name => 'BEDAREVA',
        :first_name => 'ALEXANDRA MRS',
        :passport => '4510108712',
        :ticketed_date => Date.new(2011, 8, 30),
        :price_tax => 1281,
        :price_fare => 1400,
        :validating_carrier => 'SU',
        :status => 'ticketed',
        :office_id => 'MOWR2219U',
        :validator => '92223412'
      ))
      @order.load_tickets
    end

    it "shouldn't update tickets updated by airline" do
      Amadeus.should_receive(:booking).once.and_yield(@amadeus)
      new_ticket_hash = {[1, [2, 3]] => {
        :code => "555",
        :number => "2962867063",
        :last_name => 'BEDAREVA',
        :first_name => 'ALEXANDRA MRS',
        :passport => '4510108712',
        :ticketed_date => Date.new(2011, 8, 30),
        :price_tax => 1281,
        :price_fare => 1400,
        :validating_carrier => 'SU',
        :status => 'ticketed',
        :office_id => 'LONR2219U',
        :validator => '87823412'
      }}
      pnr_resp = stub('Amadeus::Response::PNRRetrieve')
      pnr_resp.should_receive(:tickets).and_return(new_ticket_hash)
      pnr_resp.stub(:flights).and_return(nil)
      tst_resp = stub('Amadeus::Response::TicketDisplayTST')
      tst_resp.stub(:prices_with_refs).and_return({})
      @order.stub_chain(:tickets, :where, :every, :update_attribute)
      @order.stub_chain(:tickets, :reload)
      ticket = Ticket.new
      ticket.stub(:new_record?).and_return(false)
      @order.stub_chain(:tickets, :spawn).and_return(ticket)

      @amadeus.stub(:pnr_retrieve).and_return(pnr_resp)
      @amadeus.stub(:ticket_display_tst).and_return(tst_resp)

      ticket.should_receive(:update_attribute).with(:status, 'ticketed')
      @order.load_tickets
    end


    it "doesn't create empty tickets" do
      Amadeus.should_receive(:booking).once.and_yield(@amadeus)
      @order.stub(:create_notification)
      @order.save
      @order.load_tickets
      @order.tickets.length.should == 1
    end
  end

end

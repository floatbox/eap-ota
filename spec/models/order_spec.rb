require 'spec_helper'

describe Order do

  describe '#load_tickets' do
    it 'loads tickets correctly from amadeus' do
      order = Order.new(:source => 'amadeus', :commission_subagent => '1%', :pnr_number => '123456')
      order.stub_chain(:tickets, :every, :delete)
      amadeus = mock('Amadeus')

      body = File.read('spec/amadeus/xml/PNR_Retrieve_with_ticket.xml')
      doc = Amadeus::Service.parse_string(body)
      amadeus.stub(:pnr_retrieve).and_return(Amadeus::Response::PNRRetrieve.new(doc))


      body = File.read('spec/amadeus/xml/Ticket_DisplayTST_with_ticket.xml')
      doc = Amadeus::Service.parse_string(body)
      amadeus.stub(:ticket_display_tst).and_return(Amadeus::Response::TicketDisplayTST.new(doc))
      amadeus.stub(:pnr_ignore)

      Amadeus.should_receive(:booking).once.and_yield(amadeus)
      ticket = stub_model(Ticket)
      Ticket.should_receive(:find_or_create_by_number).and_return(ticket)
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
      order.load_tickets
    end
  end

end

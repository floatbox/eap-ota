# encoding: utf-8
require 'spec_helper'

describe Order do

  it "should be correctly faked by factory" do
    order = Factory.build(:order)
    order.save!
    order.errors.should be_empty
  end

  it "should not allow to create two orders with the same pnr number" do
    order1 = Order.new :pnr_number => 'foobar'
    order2 = Order.new :pnr_number => 'FOObar'
    order1.save!
    order2.save.should be_false
  end

  describe "#capitalize_pnr" do
    it "should strip spaces" do
      order = Order.new :pnr_number => '  БХЦ45 '
      order.send :capitalize_pnr
      order.pnr_number.should == 'БХЦ45'
    end

    it "should capitalize cyrillics in sirena order" do
      order = Order.new :pnr_number => 'бхЦ45'
      order.send :capitalize_pnr
      order.pnr_number.should == 'БХЦ45'
    end
  end

  describe "#create_cash_payment" do
    before(:each) do
      @order = Order.new(:pnr_number => 'XXX')
      @order.save
      @order.price_with_payment_commission = 20.2
      @order.create_cash_payment
    end

    it 'should create CashCharge' do
      @order.payments.last.should be_a(CashCharge)
    end

    it 'should create payment with correct price' do
      @order.payments.last.price.should == 20.2
    end

  end


  describe "#tickets.ensure_exists" do
    it 'should raise exception if number is blank' do
      o = Order.new
      expect { o.tickets.ensure_exists("") }.to raise_error
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
      @order.stub_chain(:tickets, :ensure_exists).and_return(ticket)
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
      pnr_resp.stub(:exchanged_tickets).and_return({})
      tst_resp = stub('Amadeus::Response::TicketDisplayTST')
      tst_resp.stub(:prices_with_refs).and_return({})
      @order.stub_chain(:tickets, :where, :every, :update_attribute)
      @order.stub_chain(:tickets, :reload)
      ticket = Ticket.new
      ticket.stub(:new_record?).and_return(false)
      @order.stub_chain(:tickets, :ensure_exists).and_return(ticket)

      @amadeus.stub(:pnr_retrieve).and_return(pnr_resp)
      @amadeus.stub(:ticket_display_tst).and_return(tst_resp)

      ticket.should_not_receive(:update_attributes)
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

  context "without commissions" do
    let (:valid_order) { Order.new :pnr_number => 'abcde' }
    subject {valid_order}
    it { should be_valid }
  end

  context "with wrong commission" do
    let (:invalid_commission) { '123,34%' }
    let (:invalid_order) { Order.new :pnr_number => 'abcde', :commission_agent => invalid_commission }
    subject {invalid_order}
    it { should_not be_valid }
  end

  describe '#api_stats_hash' do
    let(:order1){Order.new(:price_with_payment_commission=>12345.65,:route=>"SVO - KBP; KBP - LGW; LGW - KBP; KBP - SVO")}
    it 'creates correct hash' do
      order1.stub(:income).and_return(123.456798)
      orders_to_send = Order.api_stats_hash [order1]
      orders_to_send.first[:income].should == "123.46"
    end
  end
end

# encoding: utf-8
require 'spec_helper'

describe Order do

  it "should be correctly faked by factory" do
    order = build(:order)
    order.save!
  end

  describe "#update_prices_from_tickets" do
    it 'updates price_acquiring_compensation' do
      order = create(:order)
      ticket = create(:ticket, :corrected_price => (order.price_with_payment_commission * 2), :order => order)
      order.update_prices_from_tickets
      order.price_acquiring_compensation.should == ticket.price_acquiring_compensation
    end
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

    it "should string class" do
      order = Order.new :pnr_number => 'бхЦ45'
      order.send :capitalize_pnr
      order.pnr_number.class.should == String
    end
  end

  it "should set fee_scheme from config" do
    Conf.site.stub(:fee_scheme).and_return('v3')
    order = build(:order)
    order.save
    order.fee_scheme.should == 'v3'
  end

  it "sets price_acquiring_compensation before create" do
    order = build(:order)
    order.fix_price = false
    order.save
    order.price_acquiring_compensation.should == order.price_payment_commission
  end

  it 'set price_difference before save' do
    order = create(:order)
    order.price_difference.should == (order.price_with_payment_commission - order.price_real)
  end

  describe "#create_cash_payment" do

    include Commission::Fx

    subject { order.payments.last }
    before(:each) do
      order.create_cash_payment
      order.payments.reload
    end

    context "normal cash or payture order" do
      let(:order) { create(:order, :price_with_payment_commission => 20.2) }
      it {should be_a(CashCharge)}
      its(:price) {should == order.price_with_payment_commission}
      its(:commission) {should == Fx(Conf.payment.commission)}
    end

    context "normal cash or payture order" do
      let(:order) { create(:order, :price_with_payment_commission => 20.2, :pricing_method => 'corporate_0001') }
      it {should be_a(CashCharge)}
      its(:price) {should == order.price_with_payment_commission}
      its(:commission) {should == Fx(0)}
    end

  end


  describe "#tickets.ensure_exists" do
    it 'should raise exception if number is blank' do
      o = Order.new
      expect { o.tickets.ensure_exists("") }.to raise_error
    end
  end


  describe '#reload_tickets with exchange' do

    context 'with one non-zero ticket' do
      before(:all) do
        Conf.payture_alfa.stub(:commission).and_return('2.8%')
        Amadeus::Rate.stub :euro_rate => 43.0
        @order = create(:order, :price_fare => 21590, :price_tax => 9878, :price_with_payment_commission => BigDecimal('31946.68'), :source => 'amadeus', :fix_price => true)
        @old_ticket = create(:ticket, :original_price_fare => 21590.to_money("RUB"), :original_price_tax => 9878.to_money("RUB"), :kind => 'ticket', :status => 'ticketed', :code => '123', :number => '123456789', :order => @order)
        @new_ticket_hashes = [
          {:ticketed_date => Date.today - 2.days, :number => '123456787', :code => '123', :source => 'amadeus', :status => 'ticketed', :original_price_fare => 21590.to_money("RUB"), :original_price_total => 6075.to_money("RUB"), :parent_number => '123456789', :parent_code => '123', :price_fare_base => 21590.to_money("RUB")}
        ]
        Strategy.stub_chain(:select, :get_tickets).and_return(@new_ticket_hashes)
        @order.reload_tickets
        @old_ticket.reload
        @new_ticket = @order.tickets.find_by_number('123456787')
      end

      describe 'order' do
        subject { @order }
        its(:price_fare) {should == 0}
        its(:price_tax) {should == 6075}

        pending do
          its(:recalculated_price_with_payment_commission) {should == 6250}
          its(:price_tax_and_markup_and_payment) {should == 6250}
        end

      end

      describe 'old_ticket' do
        subject { @old_ticket }

        its(:original_price_fare) {should == 21590.to_money("RUB")}
        its(:price_fare) {should == 21590}
        its(:original_price_tax) {should == 9878.to_money("RUB")}
        its(:price_tax) {should == 9878}
        its(:status) {should == 'exchanged'}

        pending do
          its(:price_tax_and_markup_and_payment) {should == 10356.68}
          its(:recalculated_price_with_payment_commission) {should == 31946.68}
        end

      end

      describe 'new ticket' do
        subject { @new_ticket }

        its(:price_fare) {should == 0}
        its(:original_price_fare) {should == 0.to_money("RUB")}
        its(:price_tax) {should == 6075}
        its(:original_price_tax) {should == 6075.to_money("RUB")}
        its(:status) {should == 'ticketed'}
        its(:parent) {should == @old_ticket}

        pending do
          its(:recalculated_price_with_payment_commission) {should == 6250}
          its(:price_tax_and_markup_and_payment) {should == 6250}
        end

      end
    end

    context 'of two tickets with zero price' do
      before(:all) do
        Amadeus::Rate.stub :euro_rate => 43.0
        Conf.payture_alfa.stub(:commission).and_return('2.8%')
        @order = create(:order, :price_fare => 20010, :price_tax => 10860, :price_with_payment_commission => BigDecimal('30729.94'), :source => 'amadeus', :price_discount => -1000.5, :fix_price => true)
        @old_tickets = [1,2].map {|n| create(:ticket, :ticketed_date => Date.today - 5.days, :original_price_fare => 10005.to_money("RUB"), :original_price_tax => 5430.to_money("RUB"), :price_discount => -500.25, :kind => 'ticket', :status => 'ticketed', :code => '123', :number => "123456789#{n}", :order => @order)}
        @new_ticket_hashes = [
          {:number => '1234567871', :code => '123', :ticketed_date => Date.today - 2.days, :original_price_fare => 0.to_money("RUB"), :original_price_tax => 0.to_money("RUB"), :source => 'amadeus', :parent_id => @old_tickets[0].id, :status => 'ticketed'},
          {:number => '1234567872', :code => '123', :ticketed_date => Date.today - 2.days, :original_price_fare => 0.to_money("RUB"), :original_price_tax => 0.to_money("RUB"), :source => 'amadeus', :parent_id => @old_tickets[1].id, :status => 'ticketed'},
        ]
        Strategy.stub_chain(:select, :get_tickets).and_return(@new_ticket_hashes)
        @order.reload_tickets
        @old_ticket = @old_tickets[0]
        @old_ticket.reload
        @new_ticket = @order.tickets.find_by_number('1234567871')
      end

      describe 'order' do
        subject { @order }

        its(:price_fare) {should == 0}
        its(:price_tax_and_markup_and_payment) {should == 0}
        its(:price_tax) {should == 0}
        its(:recalculated_price_with_payment_commission) {should == 0}

      end

      describe 'old_ticket' do
        subject { @old_ticket }

        its(:original_price_fare) {should == 10005.to_money("RUB")}
        its(:price_fare) {should == 10005}
        its(:original_price_tax) {should == 5430.to_money("RUB")}
        its(:price_tax) {should == 5430}

        its(:recalculated_price_with_payment_commission) {should == 15364.97}
        its(:price_tax_and_markup_and_payment) {should == 15364.97 - 10005}

      end

      describe 'new ticket' do
        subject { @new_ticket }

        its(:original_price_fare) {should == 0.to_money("RUB")}
        its(:price_fare) {should == 0}
        its(:price_tax_and_markup_and_payment) {should == 0}
        its(:price_tax) {should == 0}
        its(:original_price_tax) {should == 0.to_money("RUB")}
        its(:recalculated_price_with_payment_commission) {should == 0}

      end
    end
  end

  describe '#load_tickets' do

    context "for sirena order" do

      it 'loads tickets correctly' do
        Sirena::Service.stub_chain(:new, :order).and_return(Sirena::Response::Order.new(File.read('spec/sirena/xml/order_with_tickets.xml')))
        Sirena::Service.stub_chain(:new, :pnr_status, :tickets_with_dates).and_return({})
        @order = Order.new(:source => 'sirena', :commission_subagent => '1%', :pnr_number => '123456', :created_at => (Time.now - 1.day))
        ticket = stub_model(Ticket, :new_record? => true)
        order_tickets = stub('order_tickets', :find_by_number => nil, :reload => nil)
        @order.stub(:tickets).and_return(order_tickets)
        order_tickets.should_receive(:create).twice.with(hash_including({:code=>"262"}))
        @order.load_tickets
      end

    end

    # FIXME это все в стратегии должно быть
    context "for amadeus order" do

      before(:each) do
        @order = build(:order, :source => 'amadeus', :commission_subagent => '1%', :pnr_number => '123456')
        @amadeus = mock('Amadeus')
        @amadeus.stub(
          pnr_retrieve:
            amadeus_response('spec/amadeus/xml/PNR_Retrieve_with_ticket.xml'),
          ticket_display_tst:
            amadeus_response('spec/amadeus/xml/Ticket_DisplayTST_with_ticket.xml'),
          pnr_ignore: nil
        )
      end

      it 'loads tickets correctly' do
        Amadeus.should_receive(:booking).once.and_yield(@amadeus)
        @order.stub_chain(:tickets, :where, :every, :update_attribute)
        ticket = stub_model(Ticket, :new_record? => true)
        order_tickets = stub('order_tickets', :find_by_number => nil, :reload => nil)
        @order.stub(:tickets).and_return(order_tickets)
        order_tickets.should_receive(:create).with(hash_including(
          :code => "555",
          :number => "2962867063",
          :last_name => 'BEDAREVA',
          :first_name => 'ALEXANDRA MRS',
          :passport => '4510108712',
          :ticketed_date => Date.new(2011, 8, 30),
          :original_price_total => 2681.to_money("RUB"),
          :original_price_fare => 1400.to_money("RUB"),
          :validating_carrier => 'SU',
          :status => 'ticketed',
          :office_id => 'MOWR2219U',
          :validator => '92223412',
          :baggage_info => ['1N']
        ))
        @order.load_tickets
      end

      it 'loads tickets with bucks correctly' do
        @order = create :order
        @new_ticket_hashes = [
          {:number => '123456787',
           :code => '123',
           :source => 'amadeus',
           :status => 'ticketed',
           :original_price_fare => 683.22.to_money("USD"),
           :original_price_tax => 192.25.to_money("USD"),
           :parent_number => '123456789',
           :parent_code => '123',
           :price_fare_base => 0.to_money("RUB"),
           :ticketed_date => Date.new(2011, 8, 30)}
        ]
        Strategy.stub_chain(:select, :get_tickets).and_return(@new_ticket_hashes)
        bank = Money::Bank::VariableExchange.new
        bank.add_rate("USD", "RUB", 31.6)
        CBR.stub(:exchange_on).with(Date.new(2011, 8, 30)).and_return(bank)
        #layered_exchange.stub(:exchange_with).and_return(31.6)
        @order.load_tickets
        @new_ticket = @order.tickets.first
        @new_ticket.original_price_fare.should == 683.22.to_money("USD")
        @new_ticket.price_fare.should == 21589.75
        @new_ticket.original_price_tax.should == 192.25.to_money("USD")
        @new_ticket.price_tax.should == 6075.10
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
        pnr_resp.stub(:additional_pnr_numbers).and_return({})
        pnr_resp.should_receive(:tickets).and_return(new_ticket_hash)
        pnr_resp.stub(:flights).and_return(nil)
        pnr_resp.stub(:exchanged_tickets).and_return({})
        tst_resp = stub('Amadeus::Response::TicketDisplayTST')
        tst_resp.stub(:money_with_refs).and_return({})
        tst_resp.stub(:baggage_with_refs).and_return({})
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
      orders_to_send = [order1.api_stats_hash]
      orders_to_send.first[:income].should == "123.46"
    end

    it "doesn't include income if such flag was set" do
      partner = mock('Partner')
      order1[:partner] = partner
      Partner.stub(:find_by_token).and_return(partner)
      partner.stub(:hide_income).and_return(true)
      orders_to_send = [order1.api_stats_hash]
      orders_to_send.first.should_not include(:income)
    end
  end

  describe '#show_vat' do
    let(:ticket_with_vat) {Ticket.new(:vat_status => '18%')}
    let(:ticket_with_unknown_vat) {Ticket.new(:vat_status => 'unknown')}
    subject do
      order = Order.new
      order.stub(:sold_tickets).and_return(tickets)
      order
    end

    context 'when vat_status of all tickets != "unknown"' do
      let(:tickets) {[ticket_with_vat, ticket_with_vat]}
      its(:show_vat) {should be_true}
    end

    context 'when vat_status of one ticket == "unknown"' do
      let(:tickets) {[ticket_with_vat, ticket_with_unknown_vat]}
      its(:show_vat) {should be_false}
    end

    context 'without sold_tickets' do
      let(:tickets) {[]}
      its(:show_vat) {should be_false}
    end
  end

  describe "prices after refund" do
    let(:order) do
      order = create(:order, :price_with_payment_commission => 3000)
      t1 = create(:ticket, :order => order)
      t2 = create(:ticket, :order => order)
      t3 = create(:refund, :order => order, :parent => t2)
      order.update_prices_from_tickets
      order
    end

    let(:active_ticket) {order.tickets.where(:status => 'ticketed').first}

    subject {order}

    its(:price_fare) {should == active_ticket.price_fare}
    its(:price_tax_and_markup_and_payment) {should == active_ticket.price_tax_and_markup_and_payment}
    its(:fee) {should == active_ticket.fee}
    its(:recalculated_price_with_payment_commission) {should == 1500}

  end

  describe "original_price_tax_as_string with bad price in tickets" do
    subject do
      build(:order).tap do |o|
        o.stub_chain(:sold_tickets, :present?).and_return(true)
        o.stub_chain(:sold_tickets, :every, :original_price_tax, :sum).and_return(0)
      end
    end

    its(:original_price_tax_as_string){should be_nil}

  end

end

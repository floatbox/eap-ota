require 'spec_helper'

describe Ticket do
  subject {ticket}

  context "#number_with_code" do
    let (:ticket) {
      described_class.new :code => '29A', :number => '1234567890-91'
    }

    its(:number_with_code) {should == '29A-1234567890-91'}
  end

  context "#recalculate_commissions" do
    context "with all the prices" do
      let (:fare) {2000}
      let (:order) {
        Order.new(
          :commission_agent => '3%',
          :commission_subagent => '4',
          :commission_consolidator => '2%',
          :commission_blanks => '50',
          :commission_discount => '2%',
          :commission_our_markup => '1%'
        )
      }
      let (:ticket) {
        Ticket.new(
          :order => order,
          :price_fare => fare
        )
      }
      before { ticket.copy_commissions_from_order }
      before { ticket.recalculate_commissions }
      its(:price_agent) {should == fare * 0.03 }
      its(:price_subagent) {should == 4}
      its(:price_consolidator) {should == fare * 0.02 }
      its(:price_blanks ) {should == 50 }
      its(:price_discount) {should == fare * 0.02 }
      its(:price_our_markup) {should == fare * 0.01 }
    end

    context "without commission_subagent" do
      let (:ticket) {
        Ticket.new(
          :price_fare => 2000
        )
      }

      before { ticket.copy_commissions_from_order }
      it "shouldn't raise error" do
        expect { ticket.recalculate_commissions }.to_not raise_error
      end

      it "shouldn't prevent saving" do
        ticket.recalculate_commissions.should_not == false
      end

    end
  end

  describe "#update_price_fare_and_add_parent" do
    it 'sets correct price_fare for ticket with fare upgrade' do
      new_ticket_hash = {:number => '123', :code => '456', :price_fare => 1000, :price_tax => 500, :parent_number => '234', :parent_code => '456', :price_fare_base => 1000}
      old_ticket = Ticket.new(:price_fare => 800, :code => '456', :number => '234', :id => 10)
      Ticket.stub_chain(:where, :first).and_return(old_ticket)
      ticket = Ticket.new(new_ticket_hash)
      ticket.valid?
      ticket.price_fare.should == 200
    end
  end

  describe "#commission_ticketing_method" do

    specify {
      Ticket.new(:source => 'amadeus', :office_id => 'MOWR2233B').commission_ticketing_method.should == 'aviacenter'
    }

    specify {
      Ticket.new(:source => 'amadeus', :office_id => 'MOWR228FA').commission_ticketing_method.should == 'direct'
    }
    specify {
      Ticket.new(:source => 'sirena').commission_ticketing_method.should == 'aviacenter'
    }
  end

  describe "#update_prices_in_order" do

    include Commission::Fx

    before do
      @order = Order.create! :pnr_number => 'abcdefgh', :commission_consolidator => '1%'
      @ticket = @order.tickets.ensure_exists '1234'
      @ticket.save!
    end

    it "should have no errors" do
      @ticket.should be_valid
    end

    it "should save ticket" do
      @ticket.should_not be_new_record
    end

    it "should store commission when saving" do
      @ticket.should_not_receive(:copy_commissions_from_order)
      @ticket.price_fare = '2000'
      @ticket.price_tax = '1000'
      @ticket.commission_consolidator = '2%'
      @ticket.commission_consolidator.should == Fx('2%')
      @ticket.save!
      @ticket.commission_consolidator.should == Fx('2%')
    end

  end
end

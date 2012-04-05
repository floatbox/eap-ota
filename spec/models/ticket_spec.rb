require 'spec_helper'

describe Ticket do
  describe "#flights=" do
    let(:cabins) {[]}
    let(:dept_dates) {['121011']}
    subject do
      flights = Recommendation.example(flight_string).flights
      flights.each_with_index {|fl, i| fl.cabin = cabins[i]} if cabins.present?
      flights.each_with_index {|fl, i| fl.departure_date = dept_dates[i]} if dept_dates.present?
      Ticket.new(:flights => flights)
    end

    context 'one way route' do
      context 'with non RF departure' do
        let_once!(:flight_string) {'cdgsvo svopee'}

        its(:vat_status) {should == '0'}
      end

      context 'with non RF arrival' do
        let_once!(:flight_string) {'ledsvo svocdg'}

        its(:vat_status) {should == '0'}
      end

      context 'with all flights inside RF' do
        let_once!(:flight_string) {'ledsvo svopee'}

        its(:vat_status) {should == '18%'}
      end

      context 'form MOW to LED thru CDG' do
        let_once!(:flight_string) {'svocdg cdgled'}

        its(:vat_status) {should == 'unknown'}
      end
    end

    context 'with return flight' do
      context 'with non RF departure' do
        let_once!(:flight_string) {'cdgsvo/su svopee/su peecdg/s7'}
        let_once!(:cabins) {['Y', 'C', 'F']}
        let_once!(:dept_dates) {['211012', '231012', '281012']}

        its(:vat_status) {should == '0'}
        its(:route) {should == 'CDG - SVO (SU); SVO - PEE (SU); PEE - CDG (S7)'}
        its(:cabins) {should == 'Y + C + F'}
        its(:dept_date) {should == Date.new(2012, 10, 21)}
      end


      context 'all but departure are outside RF' do
        let_once!(:flight_string) {'ledcdg cdgrix rixled'}

        its(:vat_status) {should == '0'}
      end

      context 'with all flights inside RF' do
        let_once!(:flight_string) {'ledpee peesvo svoled'}

        its(:vat_status) {should == '18%'}
      end

      context 'with one airport outside RF' do
        let_once!(:flight_string) {'ledpee peerix rixled'}

        its(:vat_status) {should == 'unknown'}
      end
    end
  end

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

    before(:each) do
      @old_ticket = Ticket.new(:price_fare => 1000, :code => '456', :number => '234', :id => 10)
      subject.valid?
    end

    subject do
      new_ticket_hash = {:number => '123', :code => '456', :price_fare => price_fare, :price_tax => 500, :parent_number => '234', :parent_code => '456', :price_fare_base => price_fare}
      ticket = Ticket.new(new_ticket_hash)
      ticket.stub_chain(:order, :tickets, :where).and_return([@old_ticket])
      ticket
    end

    context 'sets correct price_fare for ticket with fare upgrade' do
      let(:price_fare) {1200}
      its(:price_fare){should == 200}
    end

    context 'sets correct price_tax for ticket without fare upgrade but with nonzero price fare' do
      let(:price_fare) {1000}
      its(:price_fare) {should == 0}
      its(:price_tax){should == 1500}
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

require 'spec_helper'

describe Ticket do

  describe "#update_parent_status" do

    let (:old_ticket) {build(:ticket)}

    it "is not called  when parent is not set" do
      old_ticket.should_not_receive(:update_parent_status)
      old_ticket.save
    end

    it "updates parent status to 'exchanged' when needed" do
      old_ticket.save
      new_ticket = create(:ticket, :parent => old_ticket, :order => old_ticket.order)
      old_ticket.status.should == 'exchanged'
    end

    context "when refund" do

      before do
        old_ticket.save
      end

      let(:refund) {build(:refund, :parent => old_ticket, :order => old_ticket.order)}

      it "is doesn't try to update parent when !processed" do
        refund.status = 'pending'
        refund.save
        old_ticket.status.should == 'ticketed'
      end

      it "is called when refund is marked processed" do
        refund.should_receive(:update_parent_status)
        refund.save
      end

      it "updates parent status to 'refunded' when needed" do
        refund.save
        old_ticket.status.should == 'returned'
      end

      it 'restores parent status to "ticketed" when refund is canceled' do
        old_ticket.update_attribute(:status, 'returned')
        refund.status = 'pending'
        refund.save
        old_ticket.status.should == 'ticketed'
      end

      it 'restores parent status to "ticketed" when refund is deleted' do
        refund.save
        old_ticket.status.should == 'returned'
        refund.destroy
        old_ticket.status.should == 'ticketed'
      end

    end
  end

  describe "#set_info_from_flights" do
    let(:cabins) {[]}
    let(:dept_dates) {[]}
    subject do
      flights = Recommendation.example(flight_string).flights
      flights.each_with_index {|fl, i| fl.cabin = cabins[i]} if cabins.present?
      flights.each_with_index {|fl, i| fl.departure_date = dept_dates[i]} if dept_dates.present?
      t = Ticket.new(:flights => flights)
      t.valid?
      t
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

  describe '#update_prices_and_add_parent' do

    context 'simple ticket' do
      subject do
        new_ticket_hash = {
          :number => '123',
          :code => '456',
          :original_price_fare => original_price_fare,
          :original_price_total => original_price_total,
          :price_fare_base => original_price_fare}
        ticket = Ticket.new(new_ticket_hash)
        ticket.stub_chain(:order, :tickets).and_return([@old_ticket])
        ticket.valid?
        ticket
      end
      let(:original_price_fare) {1000.to_money("RUB")}
      let(:original_price_total) {1500.to_money("RUB")}
      its(:original_price_tax) {should == (original_price_total - original_price_fare)}
    end

    context 'exchange' do
      before(:each) do
        @old_ticket = Ticket.new(:original_price_fare => 1000.to_money("RUB"), :code => '456', :number => '2341111111', :id => 10)
        subject.valid?
      end

      subject do
        new_ticket_hash = {
          :number => '123',
          :code => '456',
          :original_price_fare => original_price_fare,
          :original_price_total => original_price_total,
          :parent_number => '2341111111',
          :parent_code => '456',
          :price_fare_base => original_price_fare}
        ticket = Ticket.new(new_ticket_hash)
        ticket.stub_chain(:order, :tickets).and_return([@old_ticket])
        ticket
      end

      let(:original_price_total){original_price_fare + 500.to_money("RUB")}

      context 'sets correct price_fare for ticket with fare upgrade' do
        let(:original_price_fare) {1200.to_money("RUB")}
        its(:original_price_fare){should == 200.to_money("RUB")}
      end

      context 'sets correct price_tax for ticket without fare upgrade but with nonzero price fare' do
        let(:original_price_fare) {1000.to_money("RUB")}

        its(:original_price_fare) {should == 0.to_money("RUB")}
        its(:original_price_tax){should == 1500.to_money("RUB")}
      end
    end
  end

  describe 'price_with_payment_commission' do
    context('with voided ticket') do
      let(:order) {create(:order)}
      subject do
        ticket = create(:ticket, :order => order)
        voided_ticket = create(:ticket, :order => order, :status => 'voided')
        ticket
      end

      its(:price_with_payment_commission) {should == order.price_with_payment_commission}
    end
  end

  describe "#commission_ticketing_method" do

    describe "factories" do
      specify { create(:ticket, :direct).commission_ticketing_method.should == 'direct' }
      specify { create(:ticket, :aviacenter).commission_ticketing_method.should == 'aviacenter' }
      let(:direct_ticket) {create(:ticket, :direct)}
      specify { create(:refund, parent: direct_ticket, order: direct_ticket.order).commission_ticketing_method.should == 'direct' }
    end

    specify {
      Ticket.new(:source => 'amadeus', :office_id => 'MOWR2233B').commission_ticketing_method.should == 'aviacenter'
    }

    specify {
      Ticket.new(:source => 'amadeus', :office_id => 'MOWR228FA').commission_ticketing_method.should == 'direct'
    }

    specify {
      Ticket.new(:source => 'amadeus', :office_id => 'FLL1S212V').commission_ticketing_method.should == 'downtown'
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

  context "should validate money fields" do
   specify { ticket = Ticket.new(:original_price_fare_as_string => "10 USD")
     ticket.original_price_fare.should == "10 USD".to_money }
   specify { ticket = Ticket.new(:original_price_tax_as_string => "10 USD")
     ticket.original_price_tax.should == "10 USD".to_money }
   specify { ticket = Ticket.new(:original_price_fare_as_string => "")
     ticket.should_not have_errors_on(:original_price_fare_as_string) }
   specify { ticket = Ticket.new(:original_price_fare_as_string => "10 usd")
     ticket.should have_errors_on(:original_price_fare_as_string)
     ticket.original_price_fare.should be_nil }
   specify { ticket = Ticket.new(:original_price_tax_as_string => "10 usd")
     ticket.original_price_tax_as_string.should == "10 usd"
     ticket.should have_errors_on(:original_price_tax_as_string)
     ticket.original_price_fare.should be_nil }
   end

end

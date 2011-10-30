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
          :commission_subagent => '4',
          :commission_consolidator_markup => '2% + 50'
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
      its(:price_share) {should == 4}
      its(:price_consolidator_markup) {should == (fare * 0.02 + 50) }
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

  describe 'should not allow to create second refund' do
    before do
      @order = Order.new(:pnr_number => 'abcde')
      @original_ticket = Ticket.create(:order => @order, :code => '29A', :number => '1234567890-91')
      @first_refund = Ticket.create(:order => @order, :parent => @original_ticket, :kind => 'refund', :comment => 'bla')
    end

    subject{
      described_class.new :parent => @original_ticket, :kind => 'refund', :comment => 'bla'
    }
    it {should_not be_valid}
    its(:save) {should_not be_true}
  end
end

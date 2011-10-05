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
      let (:ticket) {
        described_class.new(
          :price_fare => 2000,
          :commission_subagent => '4'
        )
      }
      before { ticket.recalculate_commissions }
      its(:price_share) {should == 4}
      its(:price_consolidator_markup) {should == 2000 * 0.02}
    end

    context "without commission_subagent" do
      let (:ticket) {
        described_class.new(
          :price_fare => 2000
        )
      }

      it "shouldn't raise error" do
        expect { ticket.recalculate_commissions }.to_not raise_error
      end

      it "shouldn't prevent saving" do
        ticket.recalculate_commissions.should_not == false
      end

    end
  end

  describe 'should not allow to create second refund' do
    original_ticket = Ticket.create :code => '29A', :number => '1234567890-91'
    first_refund = Ticket.create(:parent => original_ticket, :kind => 'refund')

    let (:ticket) {
      described_class.new :parent => original_ticket, :kind => 'refund'
    }
    it {should_not be_valid}
    its(:save) {should_not be_true}
  end
end

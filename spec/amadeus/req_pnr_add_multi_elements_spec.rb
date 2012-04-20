# encoding: utf-8

describe Amadeus::Request::PNRAddMultiElements do

  context "FM record" do
    subject { described_class.new(:agent_commission => agent_commission) }

    context "#agent_commisison?" do
      context "with nil agent_commission" do
        let(:agent_commission) { nil }
        its(:agent_commission?) { should be_false }
      end
      context "with empty agent_commission" do
        let(:agent_commission) { Commission::Formula.new('') }
        its(:agent_commission?) { should be_false }
      end
    end

    context "with percentage agent_commission" do
      let(:agent_commission) { Commission::Formula.new('2.23%') }
      specify { subject.agent_commission_percentage.to_s.should == '2.23' }
    end

    context "with euro agent_commission" do
      before { Conf.amadeus.stub(:euro_rate).and_return(42.5) }
      let(:agent_commission) { Commission::Formula.new('1eur') }

      it "should convert and round up euros" do
        subject.agent_commission_value.to_s.should == '43'
        subject.agent_commission_percentage.should be_false
      end
    end

    context "with roubles agent_commission" do
      let(:agent_commission) { Commission::Formula.new('24.5') }

      it "should convert and round up roubles" do
        subject.agent_commission_value.to_s.should == '25'
        subject.agent_commission_percentage.should be_false
      end
    end
  end
end

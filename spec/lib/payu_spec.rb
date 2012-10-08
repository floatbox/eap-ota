require 'spec_helper'

describe Payu do

  describe "#block" do
    let :card do end

    it "should make request wit correct params" do
      pending "need to stub date/time"
      amount = 123
      HTTParty.should receive(:post).with().and_return(stub(:payment_response))
      Payu::PaymentResponse.should receive(:new)
      Payu.new.block amount, card, :order_id => '123'
    end

  end

  describe "#unblock" do

    it "should make request wit correct params" do
      pending "need to stub date/time"
    end

  end

  describe "#add_credit_card" do
    let :card do
      CreditCard.new(
        number: '5521756777242815',
        verification_value: '912',
        year: 2014,
        month: 4,
        name: 'mr owner'
      ).tap(&:valid?)
    end

    subject { Hash.new }

    before do
      Payu.new.send :add_creditcard, subject, card
    end

    it do
      should == {
        CC_NUMBER: "5521756777242815",
        CC_TYPE: "MasterCard",
        EXP_MONTH: "04",
        EXP_YEAR: "2014",
        CC_OWNER: "mr owner",
        CC_CVV: "912"
      }
    end

  end

  describe Payu::PaymentResponse do

    subject do
      Payu::PaymentResponse.new(parsed_response)
    end

    let :parsed_response do
      HTTParty::Parser.call(body, :xml)
    end

    describe "successful block" do
      let :body do
        <<-"END"
        <?xml version="1.0"?>
        <EPAYMENT>
          <REFNO>6471185</REFNO>
          <ALIAS>31217486eb80d8981bf772cde8f2a332</ALIAS>
          <STATUS>SUCCESS</STATUS>
          <RETURN_CODE>AUTHORIZED</RETURN_CODE>
          <RETURN_MESSAGE>Authorized.</RETURN_MESSAGE>
          <DATE>2012-10-01 20:17:03</DATE>
          <HASH>8754971aa45597473707b01ea0c18d0f</HASH>
        </EPAYMENT>
        END
      end

      it {should be_success}
      it {should_not be_error}
      it {should_not be_threeds}
      its(:ref) {should == "6471185"}

    end

    describe "fraud error" do
      let :body do
        <<-"END"
        <?xml version="1.0"?>
        <EPAYMENT>
          <REFNO>6385847</REFNO>
          <ALIAS></ALIAS>
          <STATUS>FAILED</STATUS>
          <RETURN_CODE>FRAUD_RISK</RETURN_CODE>
          <RETURN_MESSAGE>Order detected with risk. Marked as fraud.</RETURN_MESSAGE>
          <DATE>2012-10-03 09:20:45</DATE>
          <HASH>01daaf323715953cf8b1cdb65aaed372</HASH>
        </EPAYMENT>
        END
      end

      it {should_not be_success}
      it {should be_error}
      it {should_not be_threeds}
      its(:ref) {should == "6385847"}

    end

    describe "duplicate ref error" do
      let :body do
        <<-"END"
        <?xml version="1.0"?>
        <EPAYMENT>
          <REFNO>6132371</REFNO>
          <ALIAS></ALIAS>
          <STATUS>FAILED</STATUS>
          <RETURN_CODE>AUTHORIZATION_FAILED</RETURN_CODE>
          <RETURN_MESSAGE>Approved.</RETURN_MESSAGE>
          <DATE>2012-10-03 10:24:08</DATE>
          <HASH>a96f0ebeb6456ebd9260bccce9619c3e</HASH>
        </EPAYMENT>
        END
      end

      it {should_not be_success}
      it {should be_error}
      it {should_not be_threeds}
      its(:ref) {should == "6132371"}

    end

    describe "success 3ds enrolled" do
      let :body do
        <<-"END"
        <?xml version="1.0"?>
        <EPAYMENT>
          <REFNO>6372861</REFNO>
          <ALIAS>3e1d8290af4191056fda5cf1d5fa9d79</ALIAS>
          <STATUS>SUCCESS</STATUS>
          <RETURN_CODE>3DS_ENROLLED</RETURN_CODE>
          <RETURN_MESSAGE>3DS Enrolled Card.</RETURN_MESSAGE>
          <DATE>2012-10-03 19:12:49</DATE>
          <URL_3DS>https://sandbox8ru.epayment.ro/order/alu_return_3ds.php?request_id=2Xrl85eqobmBr3a%2FcbnGYQ%3D%3D</URL_3DS>
          <HASH>8ed89c87509a640dc0637eeb12b3a467</HASH>
        </EPAYMENT>
        END
      end

      it {should_not be_success}
      it {should_not be_error}
      it {should be_threeds}
      its(:ref) {should == "6372861"}

    end

  end

  describe Payu::UnblockResponse do

    subject do
      Payu::UnblockResponse.new(parsed_response)
    end

    let :parsed_response do
      HTTParty::Parser.call(body, :html)
    end

    # не text/xml, поэтому не парсится HTTP::Party
    describe "success" do
      let :body do
        "<EPAYMENT>6349369|1|OK|2012-10-03 11:25:24|584fcd21ab5b74c3810fa38deb84e7e2</EPAYMENT>"
      end

      it {should be_success}
    end

    describe "fail" do
      let :body do
        "<EPAYMENT>6349369|7|Order already cancelled|2012-10-03 13:59:42|c49213a5531b2dad9b101de8b690ce36</EPAYMENT>"
      end

      it {should_not be_success}
    end

  end
end

require 'spec_helper'

describe OrderForm do
  it 'defines tk_xl correctly' do
    order_form = OrderForm.new()
    order_form.stub_chain(:recommendation, :last_tkt_date).and_return(Date.new(2011, 06, 21))
    order_form.stub_chain(:recommendation, :variants, :'[]', :departure_datetime_utc).and_return(Time.utc(11, 06, 22, 12, 30))
    Time.stub(:now).and_return(Time.local(2011, 06, 21, 21, 29))
    Date.stub(:today).and_return(Date.new(2011, 06, 21))
    order_form.tk_xl.should == Time.local(2011, 06, 22)
  end

  context "stored to cache" do
    let :recommendation do
      YAML.load_file(Rails.root + 'spec/fixtures/recommendation.yml')
    end

    let :original_order do
      OrderForm.new(
        :recommendation => recommendation,
        :people_count => {:adults => 1, :children => 0, :infants => 0},
        :variant_id => "2",
        :query_key => 'abcde',
        :partner => 'sample_partner'
      ).tap(&:save_to_cache)
    end

    specify { original_order.number.should be }

    it "shouldn't be returned on a wrong key" do
      expect{ OrderForm.load_from_cache("#{original_order.number}_no_such_key") }.to raise_error
    end

    context "and restored back correctly" do
      subject do
        OrderForm.load_from_cache(original_order.number)
      end

      it {should be}
      its(:recommendation) {should == recommendation}
      its(:people_count) {should == {:adults => 1, :children => 0, :infants => 0}}
      its(:variant_id) {should == "2"}
      its(:query_key) {should == 'abcde'}
      its(:partner) {should == 'sample_partner'}
    end
  end

  it "accepts form attributes in initializer" do
    pending
  end
end


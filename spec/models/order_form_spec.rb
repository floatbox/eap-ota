# encoding: utf-8
require 'spec_helper'

describe OrderForm do
  it 'defines tk_xl correctly' do
    order_form = OrderForm.new()
    order_form.stub_chain(:recommendation, :last_tkt_date).and_return(Date.new(2011, 06, 21))
    order_form.stub_chain(:recommendation, :source).and_return('amadeus')
    #order_form.stub(:last_tkt_date).and_return(Date.new(2011, 06, 21))
    order_form.stub_chain(:recommendation, :variants, :'[]', :departure_datetime_utc).and_return(Time.utc(2011, 06, 22, 12, 30))
    order_form.stub_chain(:recommendation, :flights, :first, :departure_datetime_utc).and_return(Time.utc(2011, 06, 22, 12, 30))
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

      context "with sample order_form attributes" do
        let(:order_attributes) do
          {"number"=>"abcdef",
           "phone"=>"81234567890",
           "email"=>"super@example.com",
           "payment_type"=>"cash"}
        end

        # triggers validation?
        # FIXME add some checks
        it "should accept them in update_attributes" do
          subject.update_attributes(order_attributes)
        end
      end
    end
  end

  context "with sample order_form attributes" do
      let(:order_attributes) do
        {"number"=>"abcdef",
         "phone"=>"81234567890",
         "email"=>"super@example.com",
         "payment_type"=>"cash"}
      end

      it "should accept them in initializer" do
        order = OrderForm.new(order_attributes)
      end
  end

  context "with person attributes" do
    # FIXME поправить параметры в соответствии с текущими контроллерами и т.п.
    # или перенести в контроллер-спек, а здесь работать только с конкретными хэшами
    let(:person_attributes) do
      {"0"=>
        {"document_noexpiration"=>"0",
         "birthday(1i)"=>"1984",
         "birthday(2i)"=>"06",
         "birthday(3i)"=>"16",
         "nationality_id"=>"170",
         #"bonuscard_type"=>"[FILTERED]",
         #"bonuscard_number"=>"[FILTERED]",
         "document_expiration_date(1i)"=>"2014",
         "document_expiration_date(2i)"=>"09",
         "document_expiration_date(3i)"=>"08",
         "sex"=>"m",
         "last_name"=>"IVASHKIN",
         "bonus_present"=>"0",
         "passport"=>"123456789",
         "first_name"=>"ALEKSEY"},
       "1"=>
        {"document_noexpiration"=>"1",
         "birthday(1i)"=>"1985",
         "birthday(2i)"=>"09",
         "birthday(3i)"=>"04",
         "nationality_id"=>"170",
         "sex"=>"f",
         "last_name"=>"IVASHKINA",
         "bonus_present"=>"0",
         "passport"=>"1234567890",
         "first_name"=>"MARIA"}
        }
      end

    let(:order) do
      order = OrderForm.new
      order.people_attributes = person_attributes
      order
    end

    it "should have two passengers" do
      order.people.size.should == 2
    end

    it "should have valid passengers" do
      order.people.first.should be_valid
      order.people.second.should be_valid
    end
  end
end


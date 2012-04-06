# encoding: utf-8
require 'spec_helper'

describe OrderForm do

  describe "#price_with_payment_commission" do
    context "when @pwpc is null" do
      it 'is taken from recommendation' do
        order_form = OrderForm.new(:price_with_payment_commission => nil)
        order_form.stub(:recommendation).and_return(mock('recommendation', :price_with_payment_commission => 100))
        order_form.price_with_payment_commission.should == 100
      end
    end

    context "when @pwpc is not null" do
      it 'is not taken from recommendation' do
        order_form = OrderForm.new(:price_with_payment_commission => 1000)
        order_form.stub(:recommendation).and_return(mock('recommendation', :price_with_payment_commission => 100))
        order_form.price_with_payment_commission.should == 1000
      end
    end
  end

  it 'defines tk_xl correctly' do
    order_form = OrderForm.new()
    order_form.stub_chain(:recommendation, :last_tkt_date).and_return(Date.new(2011, 06, 21))
    order_form.stub_chain(:recommendation, :source).and_return('amadeus')
    #order_form.stub(:last_tkt_date).and_return(Date.new(2011, 06, 21))
    order_form.stub_chain(:recommendation, :journey, :departure_datetime_utc).and_return(Time.utc(2011, 06, 22, 12, 30))
    order_form.stub_chain(:recommendation, :flights, :first, :departure_datetime_utc).and_return(Time.utc(2011, 06, 22, 12, 30))
    Time.stub(:now).and_return(Time.local(2011, 06, 21, 21, 29))
    Date.stub(:today).and_return(Date.new(2011, 06, 21))
    order_form.tk_xl.should == Time.local(2011, 06, 22)
  end

  context "stored to cache" do
    let :recommendation do
      Recommendation.from_yml(File.read(Rails.root + 'spec/fixtures/recommendation.yml'))
    end

    let :original_order do
      OrderForm.new(
        :recommendation => recommendation,
        :people_count => {:adults => 1, :children => 0, :infants => 0},
        :variant_id => "2",
        :query_key => 'abcde',
        :price_with_payment_commission => 1000,
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
      its(:price_with_payment_commission) {should == 1000}

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

  describe '#associate_infants' do

    # order_form.should have_associated( parent_last_name, infant_last_name)

    matcher :have_associated do |parent_last_name, infant_last_name|
      match do |order_form|
        parent = order_form.adults.find{|a| a.last_name == parent_last_name}
        parent.associated_infant && (parent.associated_infant.last_name == infant_last_name)
      end
    end

    matcher :have_no_infants_associated do |parent_last_name|
      match do |order_form|
        parent = order_form.adults.find{|a| a.last_name == parent_last_name}
        !parent.associated_infant
      end
    end

    matcher :have_only_one_mommy do |infant_last_name|
      match do |order_form|
        parents = order_form.adults.select{|a| a.associated_infant.try(&:last_name) == infant_last_name}
        parents.size == 1
      end
    end

    matcher :have_no_infants_associated_to_infants do
      match do |order_form|
        order_form.infants.none?(&:associated_infant)
      end
    end

    subject do
      OrderForm.new(
        :people => create_bunch_of_people(person_attrs),
        :people_count => {
          :adults => (person_attrs.count - person_attrs.count(&:second)),
           :infants => person_attrs.count(&:second),
           :children => 0
        }
      )
    end

    before { subject.associate_infants }

    context 'standart_case' do
      let(:person_attrs) {
        [
         ['ivanova'],
         ['ivanova', :infant],
         ['ivanov'],
         ['ivanov', :infant],
         ['mitrofanov'],
         ['mitrofanova', :infant],
         ['petrov', :infant],
         ['cucaev'],
         ['shmidt']
        ]
      }

      it { should have_no_infants_associated_to_infants }
      it { should have_associated('ivanova', 'ivanova') }
      it { should have_associated('ivanov', 'ivanov') }
      it { should have_associated('mitrofanov', 'mitrofanova') }
      it { should have_no_infants_associated('cucaev') }
      it { should have_associated('shmidt', 'petrov') }
    end

    context 'two adults and infant' do
      let(:person_attrs) {
        [
         ['ivanova'],
         ['ivanov'],
         ['ivanova', :infant]
        ]
      }

      it { should have_associated('ivanov', 'ivanova') }
      it { should have_no_infants_associated('ivanova') }
      it { should have_only_one_mommy('ivanova')}
    end

    def create_bunch_of_people arr
      arr.map do |last_name, infant_sign|
        person = infant_sign ? build(:infant_person) : build(:adult_person)
        person.last_name = last_name
        person
      end
    end
  end

  describe '#similar_last_names?' do
    pending { subject.send(:similar_last_names?, 'IVANOVA', 'LIKOV').should be_false }
    specify { subject.send(:similar_last_names?, 'IVANOVA', 'IVANOV').should be_true }
  end
end

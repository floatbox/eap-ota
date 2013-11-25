# encoding: utf-8
require 'spec_helper'

describe OrderForm do

  extend RSpec::Matchers::DSL

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

  describe '#needs_visa_notification' do

    subject {
      OrderForm.new(recommendation: recommendation, people: people)
    }

    context 'with flight to usa' do
      let(:recommendation) {
          Recommendation.example 'CDGJFK'
      }
      context 'with passenger from KZ' do
        let(:people){
          [Person.new(nationality_code: 'KAZ')]
        }
        its(:needs_visa_notification) {should be_true}

      end

      context 'with one passenger from GB' do
        let(:people){
          [Person.new(nationality_code: 'GBR')]
        }
        its(:needs_visa_notification) {should be_false}
      end

    end

    context 'one flight from usa' do
      let(:recommendation) {
          Recommendation.example 'LAXAMS'
      }

      context 'with passenger from UA' do
        let(:people){
          [Person.new(nationality_code: 'UKR')]
        }
        its(:needs_visa_notification) {should be_false}
      end

      context 'with one passenger from GB' do
        let(:people){
          [Person.new(nationality_code: 'GBR')]
        }
        its(:needs_visa_notification) {should be_false}
      end
    end

  end

  describe '#infants' do
    subject do
      o = OrderForm.new(:people => people)
      o.stub(:last_flight_date).and_return(Date.today + 5.days)
      o.associate_infants
      o
    end

    context 'infants after adults have priority' do
      let(:people) do
        [
          build(:person, :infant, :first_name => 'Andrei'),
          build(:person),
          build(:person, :infant, :first_name => 'Ivan')
        ]
      end
      its('infants.count') {should == 1}
      its('infants.first.first_name') {should == 'Ivan'}
    end

    context 'infant with seat is not considered as infant' do
      let(:people) do
        [
          build(:person),
          build(:person, :infant, :with_seat => true)
        ]
      end
      its(:infants) {should be_blank}

    end
  end

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
      its(:query_key) {should == 'abcde'}
      its(:partner) {should == 'sample_partner'}
      its(:price_with_payment_commission) {should == 1000}

      context "with sample order_form attributes" do
        let(:order_attributes) do
          {
            "number" => "abcdef",
            "phone" => "81234567890",
            "email" => "super@example.com",
            "payment_type" => "cash"
          }
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
        {
          "number" => "abcdef",
          "phone" => "81234567890",
          "email" => "super@example.com",
          "payment_type" => "cash"
        }
      end

      it "should accept them in initializer" do
        order = OrderForm.new(order_attributes)
      end
  end

  context "with person attributes" do
    # FIXME поправить параметры в соответствии с текущими контроллерами и т.п.
    # или перенести в контроллер-спек, а здесь работать только с конкретными хэшами
    let(:person_attributes) do
      {
        "0" => {
          "document_noexpiration" => "0",
          "birthday" => {
            "year" => "1984",
            "month" => "06",
            "day" => "16"
          },
          "nationality_code" => "RUS",
          #"bonuscard_type" => "[FILTERED]",
          #"bonuscard_number" => "[FILTERED]",
          "document_expiration" => {
            "year" => "2014",
            "month" => "09",
            "day" => "08"
          },
          "sex" => "m",
          "last_name" => "IVASHKIN",
          "bonus_present" => "0",
          "passport" => "123456789",
          "first_name" => "ALEKSEY"
        },
        "1" => {
          "document_noexpiration" => "1",
          "birthday" => {
            "year" => "1985",
            "month" => "09",
            "day" => "04"
          },
          "nationality_code" => "RUS",
          "sex" => "f",
          "last_name" => "IVASHKINA",
          "bonus_present" => "0",
          "passport" => "1234567890",
          "first_name" => "MARIA"}
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
      persons = order.people
      persons.first.should be_valid
      persons.second.should be_valid
    end
  end

  describe '#associate_infants' do

    subject do
      o = OrderForm.new(
        :people => create_bunch_of_people(person_attrs),
        :people_count => {
          :adults => (person_attrs.count - person_attrs.count(&:second)),
           :infants => person_attrs.count(&:second),
           :children => 0
        }
      )
      o.stub(:last_flight_date).and_return(Date.today + 5.days)
      o
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
      it { should have_no_infants_associated('shmidt') }
      it { should have_associated('cucaev', 'petrov') }
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
        person = infant_sign ? build(:person, :infant) : build(:person)
        person.last_name = last_name
        person
      end
    end
  end

  describe '#similar_last_names?' do
    specify { subject.send(:similar_last_names?, 'KIM', 'KIM').should be_true }
    specify { subject.send(:similar_last_names?, 'KIM', 'KAY').should be_false }
    specify { subject.send(:similar_last_names?, 'IVANOVA', 'LIKOV').should be_false }
    specify { subject.send(:similar_last_names?, 'IVANOVA', 'IVANOV').should be_true }
    specify { subject.send(:similar_last_names?, 'LIZINOV', 'LIZINOVA').should be_true }
    specify { subject.send(:similar_last_names?, 'IJIN', 'IJINA').should be_true }
    specify { subject.send(:similar_last_names?, 'IJIN', 'ABRAMOV').should be_false }
    specify { subject.send(:similar_last_names?, 'ZAYARNYI', 'ZAYARNAYA').should be_true }
  end


  describe '#calculated_people_count' do
    subject do
      last_date = Date.today + 11.months
      people = [
        build(:person),
        build(:person, :child),
        build(:person, :child, :birthday => (Date.today - 12.years + 1.month)),
        build(:person, :infant),
        build(:person, :infant),
        build(:person, :infant)
      ]
      o = OrderForm.new(:people => people)
      o.stub(:last_flight_date).and_return(last_date)
      o.associate_infants
      o
    end

    its(:calculated_people_count) {should == {:adults => 2, :children => 2, :infants => 2}}
  end
end

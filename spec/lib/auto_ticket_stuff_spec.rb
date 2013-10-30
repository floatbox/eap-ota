# encoding: utf-8
require 'spec_helper'

describe AutoTicketStuff do
  let(:flight1) {create :stored_flight}
  let(:flight2) {create :stored_flight, :dept_date => 10.days.from_now.to_date}
  let(:flight3) {create :stored_flight, :dept_date => 20.days.from_now.to_date}

  describe '#no_dupe_orders?' do
    before do
      @old_order = create(:order, :full_info => "VASYA/IVANOV\nVASYA/PETROV", :ticket_status => 'booked', :stored_flights => [flight1, flight2])
    end

    context 'real dupe' do
      subject do
        AutoTicketStuff.new(order: create(:order, :full_info => "VASYA/SIDOROV\nVASYA/IVANOV", :ticket_status => 'booked', :stored_flights => [flight2])).tap(&:no_dupe_orders?)
      end

      its(:no_dupe_orders?){should be_false}
      specify{subject.instance_variable_get(:@dupe_summary).should == "VASYA IVANOV: #{@old_order.pnr_number}"}
    end

    context 'same passengers, but different flights' do
      subject do
        AutoTicketStuff.new(order: create(:order, :full_info => "VASYA/IVANOV\nVASYA/PETROV", :ticket_status => 'booked', :stored_flights => [flight3]))
      end
      its(:no_dupe_orders?){should be_true}
    end

    context 'same flights, but different passengers' do
      subject do
        AutoTicketStuff.new(order: create(:order, :full_info => "VASYA/ONE\nVASYA/TWO", :ticket_status => 'booked', :stored_flights => [flight1, flight2]))
      end
      its(:no_dupe_orders?){should be_true}
    end
  end

  describe "#used_card_with_different_name?" do
    before do
      @old_order = create(:order, :pan => '411111xxxxxx1112', :name_in_card => 'bad passenger')
    end
    subject do
      AutoTicketStuff.new(order: create(:order, :payment_type => 'card', :pan => '411111xxxxxx1112', :name_in_card => 'another bad passenger'))
    end

    its(:used_card_with_different_name?) {should be_true}

  end

  describe "#looks_like_fraud?" do

    subject do
      AutoTicketStuff.new(order: create(:order, phone: phone), recommendation: recommendation)
    end
    let(:recommendation) do
      Recommendation.new.tap do |r|
        r.stub(:country_iatas).and_return(country_iatas)
        r.stub(:airport_iatas).and_return(city_iatas)
      end
    end
    let(:phone){'+78988787878'}
    let(:country_iatas){['RU', 'US']}
    let(:city_iatas){['LED', 'CDG']}

    context 'bad_phone' do
      let(:phone){'448988787878'}
      its(:looks_like_fraud?) {should be_true}
    end

    context 'through TFN' do
      let(:city_iatas){['LED', 'TFN', 'CDG']}
      its(:looks_like_fraud?) {should be_true}
    end

    context 'from RIX' do
      let(:city_iatas){['RIX', 'CDG']}
      its(:looks_like_fraud?) {should be_true}
    end

    context 'from Russia to BCN' do
      let(:city_iatas){['LED', 'BCN']}
      let(:country_iatas){['RU', 'ES']}
      its(:looks_like_fraud?) {should be_false}
    end

    context 'from Ukrane to BCN' do
      let(:city_iatas){['KBP', 'BCN']}
      let(:country_iatas){['UA', 'ES']}
      its(:looks_like_fraud?) {should be_true}
    end

  end

  describe '#group_booking?' do

    before do
      Order.delete_all
    end

    context '8 passengers' do
      before do
        create(:order, :blank_count => 3, :ticket_status => 'booked', :stored_flights => [flight1, flight2])
      end

      subject do
        AutoTicketStuff.new(order: create(:order, :blank_count => 5, :ticket_status => 'booked', :stored_flights => [flight2, flight3]))
      end

      its(:group_booking?) {should be_false}
    end

    context '9 passengers' do
      before do
        @old_order = create(:order, :blank_count => 3, :ticket_status => 'booked', :stored_flights => [flight1, flight2])
      end

      subject do
        AutoTicketStuff.new(order: create(:order, :blank_count => 6, :ticket_status => 'booked', :stored_flights => [flight1, flight2])).tap(&:group_booking?)
      end

      its(:group_booking?) {should be_true}
      specify{subject.instance_variable_get(:@other_order_pnrs).should == [@old_order.pnr_number]}

    end

    context 'some flights are same, some differ' do

      before do
        create(:order, :blank_count => 3, :ticket_status => 'booked', :stored_flights => [flight1, flight2])
      end

      subject do
        AutoTicketStuff.new(order: create(:order, :blank_count => 6, :ticket_status => 'booked', :stored_flights => [flight2, flight3]))
      end

      its(:group_booking?) {should be_false}
    end
  end

  describe "#unaccompanied_child?" do
    let_once!(:young_passenger) {build :person, birthday: (Date.today - 14.years)}
    let_once!(:old_passenger) {build :person, birthday: (Date.today - 18.years + 1.week)}
    let(:recommendation) do
      Recommendation.new(validating_carrier_iata: validating_carrier_iata).tap do |r|
        r.stub(:dept_date).and_return(Date.today + 1.month)
        r.stub(:marketing_carrier_iatas).and_return([marketing_carrier_iata])
        r.stub(:operating_carrier_iatas).and_return([operating_carrier_iata])
      end
    end
    let(:marketing_carrier_iata){'SU'}
    let(:validating_carrier_iata){'SU'}
    let(:operating_carrier_iata){'SU'}
    let(:people){[young_passenger]}

    subject do
      AutoTicketStuff.new(recommendation: recommendation, people: people).unaccompanied_child?
    end

    context "one 14-n year old child" do
      context "on KL carrier" do
        context 'as validating_carrier' do
          let(:validating_carrier_iata) {'KL'}
          it{should be_true}
        end

        context 'as marketing_carrier' do
          let(:marketing_carrier_iata) {'KL'}
          it{should be_true}
        end

        context 'as operating_carrier' do
          let(:operating_carrier_iata) {'KL'}
          it{should be_true}
        end
      end

      context "on SU carrier" do
        it{should be_false}
      end
    end

    context "one 18 year old person with AF carrier" do
      let(:people){[old_passenger]}
      let(:operating_carrier_iata) {'AF'}
      it{should be_false}
    end

    context "one 18 year old and one 14 year old with AF carrier" do
      let(:people){[young_passenger, old_passenger]}
      let(:operating_carrier_iata) {'AF'}
      it{should be_false}
    end

  end

end

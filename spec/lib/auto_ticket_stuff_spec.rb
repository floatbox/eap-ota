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

end

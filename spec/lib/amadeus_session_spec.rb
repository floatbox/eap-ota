# encoding: utf-8

require 'spec_helper'

describe 'session pool' do

  shared_examples_for :session_pool_store do
    let (:test_office) {'TESTOFFICE'}

    before do
      described_class.delete_all(office: test_office)
    end

    describe 'test helpers' do
      specify { create_free_session_record.should be_free }
      specify { create_stale_session_record.should be_stale }
      specify { create_booked_session_record.should be_booked }
    end

    describe ".find_free_and_book" do
      before do
        2.times { create_stale_session_record }
        3.times { create_free_session_record }
        1.times { create_booked_session_record }
        @result = described_class.find_free_and_book(office: test_office)
      end
      subject { @result.should be_booked }
      specify { described_class.free_count(test_office).should == 2 }
    end

    describe ".free_count" do
      before do
        3.times { create_free_session_record }
        2.times { create_stale_session_record }
        1.times { create_booked_session_record }
      end

      specify { described_class.free_count(test_office).should == 3 }
    end

    describe ".each_stale" do
      before do
        3.times { create_free_session_record }
        1.times { create_booked_session_record }
      end
      let (:stale_sessions) { 2.times.collect { create_stale_session_record } }

      # пока проверяет только количество и класс объектов в результате
      specify do
        expect { |block|
          described_class.each_stale(test_office, &block)
        }.to yield_successive_args(*stale_sessions.map(&:class))
      end
    end

    describe "accessors" do
      it {should respond_to(:token)}
      it {should respond_to(:seq)}
      it {should respond_to(:office)}
      it {should respond_to(:session_id)}
      it {should respond_to(:session_id=)}
      it {should respond_to(:booked?)}

      it {should respond_to(:free?)}
      it {should respond_to(:stale?)}
    end

    describe "#increment" do
      subject { create_booked_session_record }
      specify { expect {subject.increment}.to change {subject.seq}.by(1) }
    end

    describe "#book" do
      subject { create_free_session_record }
      before { subject.book }

      it { should be_booked }
      specify { described_class.free_count(test_office).should == 0 }
    end

    describe "#release" do
      subject { create_booked_session_record }
      before { subject.release }

      it { should be_free }
      specify { described_class.free_count(test_office).should == 1 }
    end

    describe "#destroy" do
      subject { create_booked_session_record }
      before { subject.destroy }

      specify { described_class.free_count(test_office).should == 0 }
    end

    describe "#booked=" do
      subject { create_free_session_record }
      before { subject.booked=true }

      it { should be_booked }
      specify { described_class.free_count(test_office).should == 0 }
    end

  end

  describe Amadeus::Session::ARStore do
    def create_free_session_record
      create(:amadeus_session_ar_store, office: test_office)
    end

    def create_stale_session_record
      create(:amadeus_session_ar_store, :stale, office: test_office)
    end

    def create_booked_session_record
      create(:amadeus_session_ar_store, :booked, office: test_office)
    end

    it_should_behave_like :session_pool_store
  end

  describe Amadeus::Session::MongoStore do
    def create_free_session_record
      create(:amadeus_session_mongo_store, office: test_office)
    end

    def create_stale_session_record
      create(:amadeus_session_mongo_store, :stale, office: test_office)
    end

    def create_booked_session_record
      create(:amadeus_session_mongo_store, :booked, office: test_office)
    end

    it_should_behave_like :session_pool_store
  end

end

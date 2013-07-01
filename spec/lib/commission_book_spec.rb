# encoding: utf-8

require 'spec_helper'

describe Commission::Book do
  describe "#find_for" do
    subject :book do
      Commission::Book.new
    end
    before do
      book.create_page carrier: 'AB'
    end

    it "should return nil when no page for carrier present" do
      book.find_for(Recommendation.new(validating_carrier_iata: 'ZZ')).should be_nil
    end

    it "should return nil when no findable commissions on page present" do
      book.find_for(Recommendation.new(validating_carrier_iata: 'AB')).should be_nil
    end

    pending "test normal matching"

  end

  describe "#find_page" do

    context "1 page" do
      subject :book do
        Commission::Book.new
      end

      before do
        @page1 = book.create_page carrier: 'AB'
      end

      it "should return nil for absent carrier" do
        book.find_page(carrier: 'UN').should be_nil
      end

      it "should find correct page for today" do
        book.find_page(carrier: 'AB').should == @page1
      end
    end

    context "3 pages" do
      subject :book do
        Commission::Book.new
      end

      before do
        @page2 = book.create_page carrier: 'AB', strt_date: Date.today, expr_date: 5.days.from_now.to_date
        @page1 = book.create_page carrier: 'AB', expr_date: 1.days.ago.to_date
        @page3 = book.create_page carrier: 'AB', strt_date: 6.days.from_now.to_date
      end

      it "should find correct page for past" do
        Timecop.freeze(2.days.ago) do
          book.find_page(carrier: 'AB').should == @page1
        end
      end

      it "should find correct page for today" do
        book.find_page(carrier: 'AB').should == @page2
      end

      it "should find correct page for future" do
        Timecop.freeze(9.days.from_now) do
          book.find_page(carrier: 'AB').should == @page3
        end
      end

      it "should reorder pages if added in wrong order" do
        book.pages_for(carrier: 'AB').should == [@page3, @page2, @page1]
      end
    end

    specify "should raise exception if entered several pages with identical strt_date" do
      expect {
        book = Commission::Book.new
        book.create_page carrier: 'AB'
        book.create_page carrier: 'AB'
      }.to raise_error(ArgumentError)
    end

  end
end

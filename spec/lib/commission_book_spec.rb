# encoding: utf-8

require 'spec_helper'

describe Commission::Book do
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
        @page1 = book.create_page carrier: 'AB', expr_date: 1.days.ago.to_date
        @page2 = book.create_page carrier: 'AB', strt_date: Date.today, expr_date: 5.days.from_now.to_date
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
    end

    pending "should reorder pages if added in wrong order"
    pending "should raise exception if entered several pages"

  end
end

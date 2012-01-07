# encoding: utf-8
require 'spec_helper'

describe Payture do

  context "faking connection" do
    use_vcr_cassette 'payture', :record => :none

    let(:first_order) { "rspec00010" }
    let(:second_order) { "rspec00011" }
    let(:amount) { 100 }
    let(:card) { Payture.test_card }

    it { subject.block(amount, card, :order_id => first_order).should be_success }
    it { subject.unblock(amount, :order_id => first_order).should be_success }

    it { subject.pay(amount, card, :order_id => second_order).should be_success }
    it { subject.refund(amount, :order_id => second_order).should be_success }
  end

  describe "#add_custom_fields" do
    let :custom_fields do
      PaymentCustomFields.new(
        :ip => '127.0.0.1',
        :first_name => 'Alexey',
        :last_name => 'Petrov',
        :phone => '12345689',
        :email => 'nobody@example.com',
        :date => Date.new(2012,11,10),
        :points => %W[SVO CDG SVO],
        :description => 'blah'
      )
    end

    it "should correctly add custom fields" do
      post = {}
      subject.send( :add_custom_fields, post, :custom_fields => custom_fields)
      # split/sort для ree
      post[:CustomFields].split(';').sort.should ==
        "IP=127.0.0.1;FirstName=Alexey;LastName=Petrov;Phone=12345689;Email=nobody@example.com;Date=2012.11.10;Segments=2;Description=blah;From=SVO;To1=CDG;To2=SVO".split(';').sort
    end

    pending "should sanitize [;= ] from custom fields values"
  end

end

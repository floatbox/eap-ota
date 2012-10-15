# encoding: utf-8
require 'spec_helper'

describe Payture do

  context "faking connection" do
    use_vcr_cassette 'payture', :record => :none

    let(:first_order) { "rspec00010" }
    let(:second_order) { "rspec00011" }
    let(:amount) { 100 }
    let(:card) { Payture.test_card }

    it { subject.block(amount, card, :our_ref => first_order).should be_success }
    it { subject.unblock(amount, :our_ref => first_order).should be_success }

    it { subject.pay(amount, card, :our_ref => second_order).should be_success }
    it { subject.refund(amount, :our_ref => second_order).should be_success }
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


  describe Payture::Response do

    subject do
      Payture::Response.new(doc)
    end

    let :doc do
      parsed_response.values.first
    end

    describe "successful" do
      let :parsed_response do
        {
          "Block" => {
            "OrderId"=>"3codesnik46001", "Success"=>"True", "Amount"=>"537210"
          }
        }
      end

      it { should be_success }
      it { should_not be_threeds }
      it { should_not be_error }
      its(:our_ref) { should == "3codesnik46001" }
      its(:amount) { should == 5372.10 }
    end

    describe "3ds" do
      let :parsed_response do
        {
          "Block" => {
            "OrderId"=>"o48582", "Success"=>"3DS", "Amount"=>"1716487",
            "ACSUrl"=>"https://acs.sbrf.ru/acs/pa?id=324102223557086",
            "PaReq"=>"eJxtUlFzgj...+ULV3DGTA==",
            "ThreeDSKey"=>"-877119-4120-110-10691094093124-38-52-72-99_p3"
          }
        }
      end

      it { should_not be_success }
      it { should be_threeds }
      it { should_not be_error }
      its(:amount) { should == 17164.87 }
      its(:our_ref) { should == "o48582" }

      its(:acs_url) { should == "https://acs.sbrf.ru/acs/pa?id=324102223557086" }
      its(:pa_req) { should == "eJxtUlFzgj...+ULV3DGTA==" }
      its(:threeds_key) { should == "-877119-4120-110-10691094093124-38-52-72-99_p3" }

    end
  end
end

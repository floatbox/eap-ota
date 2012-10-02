# encoding: utf-8
require 'spec_helper'

describe Payu do

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

  end

end

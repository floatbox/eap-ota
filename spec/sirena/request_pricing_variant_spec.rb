# encoding: utf-8
require 'spec_helper'

describe Sirena::Request::PricingVariant do

  describe '#initialize' do

    context "with pricer form" do
      let(:form){PricerForm.simple(:from => "MOV", :to => "LED", :date1 => "290912", :date2 => "300912", :infants => 1, :children => 1, :cabin => "Y")}
      subject {described_class.new form}

      it{should have(3).passengers}
      specify { subject.passengers[0][:code].should == 'ААА'  }
      specify { subject.passengers[0][:count].should == 1 }
    end

    context "with recommendation and passengers" do
      let(:response) { 'spec/sirena/xml/order_for_pricing.xml' }
      let(:order_response){Sirena::Response::Order.new( File.read(response) )}

      subject { described_class.new :recommendation => order_response.recommendation, :given_passengers => order_response.passengers }

      it{should have(3).passengers}
      specify { subject.passengers[0][:code].should == 'ААА'  }
      specify { subject.passengers[0][:count].should == 1}
    end
  end
end


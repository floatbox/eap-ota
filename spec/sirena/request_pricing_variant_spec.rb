# encoding: utf-8
require 'spec_helper'

describe Sirena::Request::PricingVariant do

  describe 'проверяем правильность работы конструктора' do

    let(:form){PricerForm.simple(:from => "MOV", :to => "LED", :date1 => "290911", :date2 => "300911", :infants => 1, :children => 1, :cabin => "Y")}
    let(:order){Sirena::Response::Order.new( File.read(response) )}
    let(:recommendation){Order.new.pricing_hash_for_sirena(order)}
    let(:response) { 'spec/sirena/xml/order_for_pricing.xml' }

    context "#priceform_given" do
      subject {described_class.new form}

      it{should have(3).passengers}
      specify { subject.passengers[0][:code].should == 'ААА'  }
      specify { subject.passengers[0][:count].should == 1 }
    end

    context "#recommendation_given" do
      subject {described_class.new recommendation}

      it{should have(3).passengers}
      specify { subject.passengers[0][:code].should == 'ААА'  }
      specify { subject.passengers[0][:count].should == 1}
    end
  end
end


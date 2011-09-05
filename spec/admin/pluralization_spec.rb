# encoding: utf-8

require 'spec_helper'

describe "russian pluralization" do
  context "should pluralize properly" do

    def pluralize_model(klass)
      klass.model_name.human.pluralize
    end

    specify { pluralize_model(Order).should == 'Заказы' }
    specify { pluralize_model(Ticket).should == 'Билеты' }
  end
end

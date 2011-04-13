require 'spec_helper'

describe 'date conversion' do

  def convert(date_str)
    PricerForm.convert_api_date(date_str)
  end

  context "should convert parameter dates in our internal format" do

    specify { convert('2010-05-02').should == '020510' }
    specify { convert('2010-08-02').should == '020810' }

  end

end

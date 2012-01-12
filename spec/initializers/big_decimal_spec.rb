require 'spec_helper'

describe BigDecimal do
  describe "#inspect" do
    specify { BigDecimal("0").inspect.should == '0' }
    specify { BigDecimal("10.0").inspect.should == '10' }
    specify { BigDecimal("2.23").inspect.should == '2.23' }
    specify { BigDecimal("2.2345").inspect.should == '2.2345' }
    specify { BigDecimal("2.2").inspect.should == '2.20' }
    # probably?
    specify { BigDecimal("-0").inspect.should == '-0' }
    specify { BigDecimal("-2.23").inspect.should == '-2.23' }
    specify { BigDecimal("-2.2345").inspect.should == '-2.2345' }
    specify { BigDecimal("-2.2").inspect.should == '-2.20' }
  end
end

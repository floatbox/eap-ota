require 'spec_helper'

describe OrderForm do
  it 'defines tk_xl correctly' do
    order_form = OrderForm.new()
    order_form.stub_chain(:recommendation, :last_tkt_date).and_return(Date.new(2011, 06, 21))
    order_form.stub_chain(:recommendation, :variants, :'[]', :departure_datetime_utc).and_return(Time.utc(11, 06, 22, 12, 30))
    Time.stub(:now).and_return(Time.local(2011, 06, 21, 21, 29))
    Date.stub(:today).and_return(Date.new(2011, 06, 21))
    order_form.tk_xl.should == Time.local(2011, 06, 22)
  end
end


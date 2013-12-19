# encoding: utf-8

describe MoneyColumns do

  # I suck and don't know how to make a virtual active record class.
  # Using exisiting one.
  let(:model) {Ticket.new}

  def set_attr value
    model.original_price_tax = value
  end

  def get_attr
    model.original_price_tax
  end

  describe "setter" do
    it "should accept Money" do
      money = "1.23".to_money("USD")
      set_attr money
      get_attr.should == money
    end

    it "should accept string" do
      string = "1.23 EUR"
      set_attr string
      get_attr.should == string.to_money
    end

    it "should accept hash" do
      hash = { "amount" => "1.23", "currency" => "EUR" }
      money = "1.23 EUR".to_money
      set_attr hash
      get_attr.should == money
    end
  end

end

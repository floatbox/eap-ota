# encoding: utf-8
describe Commission::Attrs do
  let(:test_class) do
    Class.new do
      extend Commission::Attrs
      include KeyValueInit
      has_commission_attrs :fx
    end
  end

  def casted_fx(*args)
    test_class.new(*args).fx
  end

  it "shouldn't change passed Commission" do
    fx = Commission::Formula.new('2%')
    casted_fx(:fx => fx).should == fx
  end

  it "should cast strings to Commission" do
    fx = Commission::Formula.new('2%')
    casted_fx(:fx => '2%').should == fx
  end

  it "should cast integers to Commission" do
    fx = Commission::Formula.new(2)
    casted_fx(:fx => 2).should == fx
  end

  it "should probably cast nils to zero Commission?" do
    fx = Commission::Formula.new(nil)
    casted_fx(:fx => nil).should == fx
  end

  pending "should probably return zero Commission if unset?" do
    fx = Commission::Formula.new(nil)
    casted_fx.should == fx
  end
end

# encoding: utf-8

describe SpecExtensions::LetOnce do
  class LetOnceTester
    def initialize
      @counter = 0
    end
    def increment
      @counter += 1
    end
    def counter
      @counter
    end
  end

  before(:all) do
    @tester = LetOnceTester.new
  end

  let_once! :foo do
    @tester.increment
    @tester.counter
  end

  it "should define foo" do
    foo.should == 1
  end

  # it's order dependent, but it's testing order dependence!
  it "should increment @counter only once" do
    foo.should == 1
  end

  it "'s previous test was for real. increment counter now!" do
    @tester.increment
    @tester.counter.should == 2
  end

  it "'s previous test was for real and persistent in effect" do
    @tester.counter.should == 2
  end

  describe "subject_once!" do
    subject_once! { LetOnceTester.new.tap(&:increment) }
    specify { subject.should be_a(LetOnceTester) }
    specify { subject.counter.should == 1}
    specify { subject.increment; subject.counter.should == 2}
    specify { subject.counter.should == 2}

    context "nested context for subject" do
      subject { "foo" }
      it "should allow redefine subject normally" do
        subject.should == "foo"
      end
    end

    context "nested context for subject_once!" do
      subject_once! { "bar" }
      it "should redefine subject" do
        subject.should == "bar"
      end
    end
  end
end

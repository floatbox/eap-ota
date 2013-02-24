# encoding: utf-8
# require 'spec_helper'

require 'parsers/alfabank'

describe Parsers::Alfabank do
  describe "parse_date" do
    let(:instance) { Parsers::Alfabank.allocate }
    subject { instance.send(:parse_date, '17.09.12', '12:54') }
    it {should == DateTime.new(2012, 9, 17, 12, 54)}

    pending  "it's timezone should be MSK"
  end

  describe "parse" do
    context "S121928.262" do
      let(:filename) { "spec/parsers/alfabank/S121928.262" }
      let(:contents) { File.open(filename, 'r:binary') {|f| f.read } }
      subject { Parsers::Alfabank.new(contents, filename).parse }

      it { should have(100).items }
      its(:first) do
        should include(foo:'bar')
      end
    end
  end
end

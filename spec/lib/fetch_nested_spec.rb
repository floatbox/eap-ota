# encoding: utf-8

require 'spec_helper'

describe "Hash#nested" do
  before do
    class Hash
      # Fetches deep nested hash value by its dot-separated path
      #
      # hash = {'foo' => {'bar' => {'baz' => 3}}}
      # hash.nested('foo.bar.baz')
      # => 3
      # hash.nested('foo.key')
      # => nil
      # hash.nested('foo.key', 5)
      # => 5
      def nested(path, default_value=nil)
        path.split('.').reduce(self) do |hash, partial_key|
          hash[partial_key] or return default_value
        end
      end
    end
  end

  it "should return value for a simple string key" do
    {'foo' => 3}.nested('foo').should == 3
  end

  it "should return value for a nested string key" do
    {'foo' => {'bar' => {'baz' => 3}}}.nested('foo.bar.baz').should == 3
  end

  it "should return nil for a nonexistent key" do
    {'foo' => {'bar' => {'baz' => 3}}}.nested('foo.key').should be_nil
  end

  it "should return default_value for a nonexistent key" do
    {'foo' => {'bar' => {'baz' => 3}}}.nested('foo.key', 5).should == 5
  end

  pending "should return value if it is false, instead of default_value" do
    {'foo' => false}.nested('foo').should == false
  end

  pending "should react somehow, if partial path is not pointing to a hash" do
    {'foo' => 2}.nested('foo.bar').should be_nil
  end

  pending "should work with arrays too!" do
    {'foo' => [1, {'bar' =>2}]}.nested('foo.1.bar').should == 2
  end

end

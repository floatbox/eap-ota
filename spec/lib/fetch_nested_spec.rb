# encoding: utf-8

require 'spec_helper'

describe "FetchNested#nested" do
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

  it "should return value if it is false, instead of default_value" do
    {'foo' => false}.nested('foo').should == false
  end

  it "should react somehow, if partial path is not pointing to a hash" do
    {'foo' => 2}.nested('foo.bar').should be_nil
  end

  pending "should work with arrays too!" do
    {'foo' => [1, {'bar' =>2}]}.nested('foo.1.bar').should == 2
  end

  it "should return proxy, if called without args" do
    {'foo' => 2}.nested.should be_a(FetchNested::Proxy)
  end

  context "as proxy" do

    # copy-pasta! ugly me.
    context "[] getter" do
      it "should return value for a simple string key" do
        {'foo' => 3}.nested['foo'].should == 3
      end

      it "should return value for a nested string key" do
        {'foo' => {'bar' => {'baz' => 3}}}.nested['foo.bar.baz'].should == 3
      end

      it "should return nil for a nonexistent key" do
        {'foo' => {'bar' => {'baz' => 3}}}.nested['foo.key'].should be_nil
      end

      it "should return default_value for a nonexistent key" do
        {'foo' => {'bar' => {'baz' => 3}}}.nested['foo.key', 5].should == 5
      end

      it "should return value if it is false, instead of default_value" do
        {'foo' => false}.nested['foo'].should == false
      end

      it "should react somehow, if partial path is not pointing to a hash" do
        {'foo' => 2}.nested['foo.bar'].should be_nil
      end
    end

    context "[]= setter" do
      it "should assign value for a simple string key" do
        hash = {}
        hash.nested['foo'] = 3
        hash.should == {'foo' => 3}
      end

      it "should assign value for a nested string key" do
        hash = {'foo' => {'bar' => {'baz' => 5}}}
        hash.nested['foo.bar.baz'] = 3
        hash.should == {'foo' => {'bar' => {'baz' => 3}}}
      end

      it "should assign to a nonexistent key" do
        hash = {'foo' => {'bar' => {}}}
        hash.nested['foo.bar.baz'] = 3
        hash.should == {'foo' => {'bar' => {'baz' => 3}}}
      end

      it "should create intermediate nodes to a nonexistent key" do
        hash = {}
        hash.nested['foo.key.baz'] = 5
        hash.should == {'foo' => {'key' => {'baz' => 5}}}
      end

      it "should replace key, if partial path is not pointing to a hash" do
        hash = {'foo' => 2}
        hash.nested['foo.bar'] = 5
        hash.should == {'foo' => {'bar' => 5}}
      end
    end
  end
end

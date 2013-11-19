# encoding: utf-8
require 'spec_helper'

describe Context do
  describe "#initialize" do
    it "won't fail" do
      Context.new( deck_user: Deck::User.new )
    end
  end

  describe "#pricer_sort?" do
  end

  describe "#pricer_filter?" do
  end

  describe "#pricer_suggested_limit" do
  end
end

# encoding: utf-8
require 'spec_helper'

describe HotOffer do
  let(:hot_offer_attributes) do
   {
     "code" => "gu43gk",
     "url" => "http://localhost:3000/#gu43gk",
     "description" => "Москва ⇄ Лондон",
     "price" => "8629",
     "for_stats_only" => "false",
     "destination_id" => 20420,
     "time_delta" => 16,
     "price_variation" => 0,
     "price_variation_percent" => 0
   }
  end

  subject { HotOffer.new(hot_offer_attributes).tap(&:valid?) }

  its(:url) {should == "http://localhost:3000/#gu43gk"}
end

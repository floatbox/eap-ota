# encoding: utf-8
require 'spec_helper'

describe PricerForm do
  subject do
    described_class.new( attrs )
  end

  let :people_attrs do
    {"infants"=>"0", "adults"=>"1", "children"=>"0"}
  end

  context "when filled" do
    let :attrs do
      { "people_count" => people_attrs,
        "form_segments" => {
          "0" => {"from"=>"Москва", "date"=>"210411", "to"=>"Париж"},
          "1" => {"from"=>"Париж", "date"=>"280411", "to"=>"Москва"}}
      }
    end

    it do
      should be_valid
    end
  end

  context "when second row 'from' is not filled" do
    let :attrs do
      { "people_count" => people_attrs,
        "form_segments"=> {
          "0" => {"from"=>"Москва", "date"=>"210411", "to"=>"Париж"},
          "1" => {"from"=>"", "date"=>"280411", "to"=>"Москва"}}
      }
    end

    it do
      should be_valid
    end
  end
end
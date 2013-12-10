require 'spec_helper'

describe AviaSearchSerializer do

  subject { json }
  let (:json) { AviaSearchSerializer.new(search).as_json }
  let (:search) { AviaSearch.from_code(code) }

  describe "valid code" do
    let (:code) { 'MOW-PAR-23Jun-25Sep-2adults-child-business' }

    its ([:query_key]) {should == code }
    its ([:valid]) {should == true }
  end

  describe "invalid code" do
    let (:code) { 'MOWPARR' }

    its ([:valid]) {should be_nil }
  end
end

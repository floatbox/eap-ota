# encoding: utf-8
require 'spec_helper'

describe GeoTagging do
  before(:each) do
    @valid_attributes = {
      :geo_tag_id => 1,
      :location => City.new
    }
  end

  it "should create a new instance given valid attributes" do
    GeoTagging.create!(@valid_attributes)
  end
end

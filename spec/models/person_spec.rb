# encoding: utf-8
require 'spec_helper'

describe Person do
  let(:adult_attributes) do
    {"document_noexpiration"=>"0",
     "birthday(1i)"=>"1984",
     "birthday(2i)"=>"06",
     "birthday(3i)"=>"16",
     "nationality_id"=>"170",
     #"bonuscard_type"=>"[FILTERED]",
     #"bonuscard_number"=>"[FILTERED]",
     "document_expiration_date(1i)"=>"2014",
     "document_expiration_date(2i)"=>"09",
     "document_expiration_date(3i)"=>"08",
     "sex"=>"m",
     "last_name"=>"IVASHKIN",
     "bonus_present"=>"0",
     "passport"=>"123456789",
     "first_name"=>"ALEKSEY"}
  end

  subject { Person.new(adult_attributes) }

  its(:birthday) {should == Date.new(1984, 6, 16)}
  its(:document_expiration_date) {should == Date.new(2014, 9, 8)}
end

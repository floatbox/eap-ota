require 'spec_helper'

describe Ticket do
  let (:ticket) {
    described_class.new :code => '29A', :number => '1234567890-91'
  }

  subject {ticket}
  its(:number_with_code) {should == '29A-1234567890-91'}
end


# encoding: utf-8
require 'spec_helper'

describe Sirena::Response::PnrStatus do

  subject { described_class.new( File.read(response) ) }

  describe "#tickets_with_dates" do

    let(:response) { 'spec/sirena/xml/pnr_status_with_tickets.xml' }
    ticket_date = Date.new(2011, 9, 14)
    its('tickets_with_dates') {should == {'6150617647' => ticket_date, '6150617648' => ticket_date, '6150617649' => ticket_date}}

  end

end


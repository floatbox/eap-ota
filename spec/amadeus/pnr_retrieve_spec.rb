# encoding: utf-8
require 'spec_helper'

describe Amadeus::Response::PNRRetrieve do

  describe 'with complex exchange' do

    let_once! :response do
      amadeus_response('spec/amadeus/xml/PNR_Retrieve_with_complex_exchange.xml')
    end

    subject {response}

    specify { subject.parsed_exchange_string('PAX 258-2963040411MOW13SEP11/92223412/258-29630404111E1').should == {:code => '258', :number => '2963040411', :inf => 'PAX'} }
    it {should have(4).exchanged_tickets}
    specify { subject.exchanged_tickets.should have_key([[1, "a"], [13, 14]])}
    specify { subject.exchanged_tickets[[[1, "a"], [13, 14]]].should == {:code => '169', :number => '2963040413'} }

  end

  context 'with double partly flown exchange' do

    let_once! :response do
      amadeus_response('spec/amadeus/xml/PNR_Retrieve_with_double_exchange.xml')
    end

    subject {response}

    its(:exchanged_tickets) {should == {[[7, "a"], [3, 4, 6, 7]] =>
                  {:number=>"9460734984", :code=>"784"},
                                        [[6, "a"], [3, 4, 6, 7]] =>
                  {:number=>"9460734985", :code=>"784"}}
      }

  end

  describe 'with another complex exchange' do

    let_once! :response do
      amadeus_response('spec/amadeus/xml/PNR_Retrieve_with_another_exchange.xml')
    end

    subject {response}

    it {should have(1).exchanged_tickets}
    specify { subject.parsed_exchange_string('603-2962817528-29MOW28AUG11/92223412/603-29628175286E1-294').should == {:code => '603', :number => '2962817528', :inf => nil} }
    specify { subject.exchanged_tickets.should have_key([[1, "a"], [1, 3]])}
    specify { subject.exchanged_tickets[[[1, "a"], [1, 3]]].should == {:code => '603', :number => '2962817528'} }

  end

  describe 'with two adults, children and infant' do

    let_once! :response do
      amadeus_response('spec/amadeus/xml/PNR_Retrieve_TwoAdultsWithChildren.xml')
    end

    subject { response }

    it { should be_success }
    it { should have(4).passengers }
    specify { subject.passengers.collect{|p| p.tickets.every.number_with_code}.should ==  [['220-2791248713'], ['220-2791248714'], ['220-2791248716-17'], ['220-2791248715']]  }
    specify { subject.passengers.collect(&:last_name).should == ['MITROFANOV', 'MITROFANOVA', 'MITROFANOVA', 'MITROFANOVA'] }
    specify { subject.passengers.collect(&:first_name).should == ['PAVEL MR', 'VALENTINA MRS', 'MARIA', 'ARINA'] }
    specify { subject.passengers.collect(&:passport).should == ['111116818', '222228156', '333335276', '444442618'] }
    specify { subject.passengers.find_all{|p| p.infant_or_child == 'i'}.length.should == 1 }
    specify {subject.all_segments_available?.should == true}
    its(:complex_tickets?) {should be_false}
    its(:email) { should == 'PAVEL@EXAMPLE.COM' }
    its(:phone) { should == '+75557777555' }
    its(:validating_carrier_code) { should == 'LH' }

  end

  describe 'three passengers, but only two tickets' do

    let_once! :response do
      amadeus_response('spec/amadeus/xml/PNR_Retrieve_Strange_Ticket_Number.xml')
    end

    subject { response }

    it { should be_success }
    it { should have(3).passengers }
    specify { subject.passengers.collect{|p| p.tickets.every.number_with_code}.should == [['006-2791485245'], ['006-2791485244'], []]  }

  end

  describe 'with exchange of flwn ticket' do

    let_once! :response do
      amadeus_response('spec/amadeus/xml/PNR_Retrieve_with_broken_lt.xml')
    end

    subject { response }
    its('exchanged_tickets.keys') {should == [[[1, "a"], [6, 7]]]}


  end

  describe 'with cancelled by airline segments' do
    let_once! :response do
      amadeus_response('spec/amadeus/xml/PNR_Retrieve_with_cancelled_by_airline_segments.xml')
    end

    subject { response }

    specify {subject.all_segments_available?.should == false}

  end

  describe 'with additional pnr numbers' do
    let_once! :response do
      amadeus_response('spec/amadeus/xml/PNR_Retrieve_with_cancelled_by_airline_segments.xml')
    end

    subject { response }

    specify {subject.additional_pnr_numbers.should == {'OK' => 'ZF10C', 'SU' => 'SUPNR'}}
    #subject.additional_pnr_numbers.should == {
    its(:validating_carrier_code) { should == 'OK' }
  end

  describe "#complex_tickets" do
    let_once! :response do
      amadeus_response('spec/amadeus/xml/PNR_Retrieve_complex_tickets.xml')
    end

    subject { response }

    its(:complex_tickets?) {should be_true}
  end

  describe "#parse_ticket_string" do

    describe 'simple parse' do

      subject {
        Amadeus::Response::PNRRetrieve.new('').parsed_ticket_string('INF 220-2791248716-17/ETLH/RUB120/25FEB11/MOWR2219U/92223412')
      }

      its([:code]) { should == '220' }
      its([:number]) { should == '2791248716-17' }
      its([:status]) { should == 'ticketed' }
      its([:ticketed_date]) { should == Date.new(2011, 2, 25) }
      its([:validating_carrier]) { should == 'LH' }
      its([:office_id]) { should == 'MOWR2219U' }
      its([:validator]) { should == '92223412' }
    end

    describe 'with dot in currency' do

      subject {
        Amadeus::Response::PNRRetrieve.new('').parsed_ticket_string('PAX 996-2400495502/ETUX/EUR0.00/12SEP11/PMIUX0002/78494264')
      }

      it {should be_present}
      its([:code]) { should == '996' }
      its([:number]) { should == '2400495502' }
      its([:status]) { should == 'ticketed' }
      its([:ticketed_date]) { should == Date.new(2011, 9, 12) }
      its([:validating_carrier]) { should == 'UX' }
      its([:office_id]) { should == 'PMIUX0002' }
      its([:validator]) { should == '78494264' }
    end

    describe 'without currency' do

      subject {
        Amadeus::Response::PNRRetrieve.new('').parsed_ticket_string('PAX 566-2962622407/ETPS/09AUG11/MOWR2219U/92223412')
      }

      it {should be_present}
      its([:code]) { should == '566' }
      its([:number]) { should == '2962622407' }
      its([:status]) { should == 'ticketed' }
      its([:ticketed_date]) { should == Date.new(2011, 8, 9) }
      its([:validating_carrier]) { should == 'PS' }
      its([:office_id]) { should == 'MOWR2219U' }
      its([:validator]) { should == '92223412' }
    end
  end

  describe "#tickets" do

    context "with service tickets" do

      subject {
        amadeus_response('spec/amadeus/xml/PNR_Retrieve_with_service_tickets.xml')
      }

      its(:tickets) {should be_present}
    end

    context "two tickets for one passenger" do

      let_once! :response do
        amadeus_response('spec/amadeus/xml/PNR_Retrieve_complex_tickets.xml')
      end

      subject { response }

      specify { subject.passengers.collect{|p| p.tickets.every.number_with_code}.should ==  [["074-2962537981", "047-2962537982"], ["074-2962537980", "047-2962537983"]]}

      its("tickets.present?"){should be_true}
      its('tickets.keys.length'){should == 4}
      its('tickets.keys'){should include([[2, 'a'], [5, 6, 7, 8]])}
      its('tickets.keys'){should include([[1, 'a'], [5, 6, 7, 8]])}
      its('tickets.keys'){should include([[1, 'a'], [11, 12]])}
      its('tickets.keys'){should include([[2, 'a'], [11, 12]])}
      specify{subject.tickets[[[2, 'a'], [5, 6, 7, 8]]][:first_name].should == 'GENNADY MR'}
      specify{subject.tickets[[[2, 'a'], [5, 6, 7, 8]]][:last_name].should == 'NEDELKO'}
      specify{subject.tickets[[[2, 'a'], [5, 6, 7, 8]]][:flights].every.marketing_carrier_iata.should == ['AZ','AZ','KL','KL']}
      specify{subject.tickets[[[2, 'a'], [5, 6, 7, 8]]][:flights].every.cabin.should == ['S', 'S', 'R', 'R']}
      specify{subject.tickets[[[2, 'a'], [5, 6, 7, 8]]][:passport].should == '714512085'}

    end

    context "with infant" do
      let_once! :response do
        amadeus_response('spec/amadeus/xml/PNR_Retrieve_TwoAdultsWithChildren.xml')
      end

      subject { response.tickets }

      specify{subject[[[14, 'a'], [1, 2]]][:first_name].should == 'VALENTINA MRS'}
      specify{subject[[[14, 'i'], [1, 2]]][:first_name].should == 'MARIA'}
      specify{subject[[[14, 'a'], [1, 2]]][:number].should == '2791248714'}
      specify{subject[[[14, 'i'], [1, 2]]][:number].should == '2791248716-17'}
      specify{subject[[[14, 'a'], [1, 2]]][:last_name].should == 'MITROFANOVA'}
      specify{subject[[[14, 'i'], [1, 2]]][:last_name].should == 'MITROFANOVA'}
    end

  end

  describe "#fm" do
    context "percents" do
      body = File.read('spec/amadeus/xml/PNR_Retrieve_with_ticket.xml')
      doc = Amadeus::Service.parse_string(body)
      specify{Amadeus::Response::PNRRetrieve.new(doc).fm.should == "7%"}
    end
    context "rubles" do
      body = File.read('spec/amadeus/xml/PNR_Retrieve_TwoAdultsWithChildren.xml')
      doc = Amadeus::Service.parse_string(body)
      specify{Amadeus::Response::PNRRetrieve.new(doc).fm.should == "1"}
    end
  end

end


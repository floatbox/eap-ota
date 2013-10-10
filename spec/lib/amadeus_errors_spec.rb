# encoding: utf-8
require 'spec_helper'

describe Amadeus::SoapError do

  describe ".wrap" do
    def handsoap_fault(reason)
      Handsoap::Fault.new('soap:Something', reason, nil)
    end

    {
      Amadeus::SoapSyntaxError => [
        # soap:Server
        '18|Application|The backend didn\'t understand the incoming query. Please contact your helpdesk.',
        '3973|Application|INVALID EDIFACT FORMAT',
        # soap:Client
        '18|Presentation|',
        '18|Presentation|Fusion DSC found an exception ! Too many occurences of an element: Current element: traveller According to the grammar, max repetition number is 9 for this element Curr...',
        '18|Presentation|Fusion DSC found an exception ! Missing Mandatory tag : Expected element: traveller Current position in buffer: /paxReference fareOptions Last 15 characters before erro...',
        '18|Presentation|Fusion DSC found an exception ! The data does not match the maximum length: For data element: freetext Data length should be at least 1 and at most 70 Current position...'
      ],
      Amadeus::SoapApplicationError => [
        # soap:Server
        '1931|Application|NO MATCH FOR RECORD LOCATOR',
        '284|Application|SECURED PNR',
        '31|Application|FINISH OR IGNORE',
        '91|Application|Unknown error'
      ],
      Amadeus::SoapNetworkError => [
        # soap:Server
        '42|Application|Too many opened conversations. Please close them and try again.',
        ' 42|Transport|Temporary network error:unable to reach targeted application',
        '357|Application|LINK DOWN',
        '2162|Application|LINK DOWN - RETRY IN 2 MINUTES',
        # soap:Client
        ' 93|Session|Illogical conversation'
      ]
    }.each do |exception, handsoap_reasons|
      context exception.to_s do
        handsoap_reasons.each do |reason|
          it "should be returned for #{reason.inspect}" do
            Amadeus::SoapError.wrap(handsoap_fault(reason)).should be_an(exception)
          end
        end
      end
    end

  end

end

module Amadeus
  class Error < StandardError
  end

  class SoapError < StandardError
    include Errors::Nested
  end
end

# rescue Handsoap::Fault => e
#  raise Amadeus::Error, e.reason

# Handsoap::Fault
# code, reason

# Syntax Errors
#
#'soap:Server', '18|Application|The backend didn't understand the incoming query. Please contact your helpdesk.'
#'soap:Client', '18|Presentation|'
#'soap:Client', '18|Presentation|Fusion DSC found an exception ! Too many occurences of an element: Current element: traveller According to the grammar, max repetition number is 9 for this element Curr...'
#'soap:Client', '18|Presentation|Fusion DSC found an exception ! Missing Mandatory tag : Expected element: traveller Current position in buffer: /paxReference fareOptions Last 15 characters before erro...'
#'soap:Client', '18|Presentation|Fusion DSC found an exception ! The data does not match the maximum length: For data element: freetext Data length should be at least 1 and at most 70 Current position...'
#
#'soap:Server', '3973|Application|INVALID EDIFACT FORMAT'
#
# Application Errors
#
#'soap:Server', '1931|Application|NO MATCH FOR RECORD LOCATOR'
#'soap:Server', '284|Application|SECURED PNR'
#
#'soap:Server', '31|Application|FINISH OR IGNORE'
#'soap:Server', '91|Application|Unknown error'
#
# Session and Network Errors
#
#'soap:Server', '42|Application|Too many opened conversations. Please close them and try again.'
#'soap:Server', ' 42|Transport|Temporary network error:unable to reach targeted application'
#
#'soap:Server', '357|Application|LINK DOWN'
#'soap:Server', '2162|Application|LINK DOWN - RETRY IN 2 MINUTES'
#
#'soap:Client', ' 93|Session|Illogical conversation'


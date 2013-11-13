class Alfastrah
  module Calculation
    class Request < Alfastrah::Base::Request
      attribute :pnr, String
      attribute :passengers, Array[Alfastrah::Passenger]
      attribute :segments, Array[Alfastrah::Segment]

      validates :pnr, :passengers, :segments, presence: true, allow_blank: false

      def endpoint
        'calculatePolicy'
      end

      def build_xml
        x = Builder::XmlMarkup.new
        x.soapenv :Envelope, 'xmlns:soapenv' => 'http://schemas.xmlsoap.org/soap/envelope/', 'xmlns:trav' => 'http://vtsft.ru/travelExtService/' do
          x.soapenv :Header
          x.soapenv :Body do
            x.trav :calculatePolicyRequest do
              x.trav :operator do
                x.trav :code, 'eviterra'
              end
              x.trav :product do
                x.trav :code, 'EVITERRA-FLIGHT'
              end
              x.trav :policyParameters do
                x.trav :PNR, pnr

                build_passengers_xml x, passengers

                x.trav :flightSegmentsCount, segments.count

                build_segments_xml x, segments
              end
            end
          end
        end
      end
    end
  end
end

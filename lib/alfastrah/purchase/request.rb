module Alfastrah
  module Purchase
    class Request < Alfastrah::Base::Request
      attribute :pnr, String
      attribute :passengers, Array[Alfastrah::Passenger]
      attribute :segments, Array[Alfastrah::Segment]
      attribute :payment_type, String

      validates :pnr, :passengers, :segments, :payment_type, presence: true, allow_blank: false

      def endpoint
        'createPolicy'
      end

      def build_xml
        x = Builder::XmlMarkup.new
        x.soapenv :Envelope, 'xmlns:soapenv' => 'http://schemas.xmlsoap.org/soap/envelope/', 'xmlns:trav' => 'http://vtsft.ru/travelExtService/' do
          x.soapenv :Header
          x.soapenv :Body do
            x.trav :createPolicyRequest do
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

                x.trav :paymentType, payment_type
              end
            end
          end
        end
      end
    end
  end
end

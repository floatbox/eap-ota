module Alfastrah
  module Calculation
    class Request
      include Virtus.model

      attribute :pnr, String
      attribute :passengers, Array[Alfastrah::Passenger]
      attribute :segments, Array[Alfastrah::Segment]

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

                build_passengers_xml x

                x.trav :flightSegmentsCount, segments.count

                build_segments_xml x
              end
            end
          end
        end
      end

      def build_passengers_xml x
        passengers.each_with_index do |passenger, idx|
          x.trav :insuredFirstName,      {seqNo: idx}, passenger.first_name
          x.trav :insuredLastName,       {seqNo: idx}, passenger.last_name
          x.trav :insuredBirthDate,      {seqNo: idx}, passenger.birth_date
          x.trav :insuredDocumentType,   {seqNo: idx}, passenger.document_type
          x.trav :insuredDocumentNumber, {seqNo: idx}, passenger.document_number
        end
      end

      def build_segments_xml x

      end
    end
  end
end

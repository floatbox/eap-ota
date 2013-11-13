module Alfastrah
  module Base
    class Request
      include Virtus.model
      include ActiveModel::Validations

      def endpoint
        raise NotImplementedError
      end

      def build_xml
        raise NotImplementedError
      end

      private

      def build_passengers_xml x, passengers
        passengers.each_with_index do |passenger, idx|
          x.trav :insuredFirstName,      {seqNo: idx}, passenger.first_name
          x.trav :insuredLastName,       {seqNo: idx}, passenger.last_name
          x.trav :insuredBirthDate,      {seqNo: idx}, passenger.birth_date
          x.trav :insuredTicketNumber,   {seqNo: idx}, passenger.ticket_number
          x.trav :insuredDocumentType,   {seqNo: idx}, passenger.document_type
          x.trav :insuredDocumentNumber, {seqNo: idx}, passenger.document_number
        end
      end

      def build_segments_xml x, segments
        segments.each_with_index do |segment, idx|
          x.trav :flightSegmentTransportOperatorCode, {seqNo: idx} do
            x.trav :value, segment.carrier_code
          end
          x.trav :flightSegmentFlightNumber,          {seqNo: idx} do
            x.trav :value, segment.flight_number
          end
          x.trav :flightSegmentDepartureDate,         {seqNo: idx} do
            x.trav :value, segment.depart_date
          end
          x.trav :flightSegmentDepartureAirport,      {seqNo: idx} do
            x.trav :value, segment.origin_iata
          end
          x.trav :flightSegmentArrivalDate,           {seqNo: idx} do
            x.trav :value, segment.arrival_date
          end
          x.trav :flightSegmentArrivalAirport,        {seqNo: idx} do
            x.trav :value, segment.destination_iata
          end
        end
      end
    end
  end
end

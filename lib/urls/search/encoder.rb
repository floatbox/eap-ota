# encoding: utf-8

require 'urls/search'

module Urls
  module Search
    module Encodable
      def encode_url
        encoder = Encoder.new(self)
        encoder.url
      end
    end

    class Encoder
      attr_reader :url

      def initialize(search)
        @url = nil
        @valid = encode_search(search)
      end

      def valid?
        @valid
      end

      private

      def encode_search(search)
        cabin = search.cabin.to_s
        adults = search.adults.to_s
        children = search.children.to_s
        infants = search.infants.to_s
        segments = encode_segments(search.segments)

        @url = cabin + adults + children + infants + segments
        true
      end

      def encode_segments(segments)
        encoded_segments = segments.map do |segment|
          # date_as_date - специфика текущего PricerForm
          encode_iata(segment.from_iata) + 
            encode_iata(segment.to_iata) + 
            encode_date(segment)
        end
        encoded_segments.join
      end

      def encode_date(segment)
        segment.date_as_date.strftime('%d%b').upcase
      end

      def encode_iata(iata)
        iata = ::Unicode.upcase(iata)
        if iata.size == 2
          iata + Urls::Search::FILLER_CHARACTER
        else
          iata
        end
      end
    end
  end
end


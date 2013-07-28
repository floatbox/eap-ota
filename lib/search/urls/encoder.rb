# encoding: utf-8

require 'search/urls'

module Search
  module Urls

    class Encoder
      attr_reader :url

      SEGMENT_SEPARATOR = '-'
      INTERNAL_SEPARATOR = '-'

      def initialize(search)
        @url = nil
        @valid = encode_search(search)
      end

      def valid?
        @valid
      end

      private

      def encode_search(search)
        @url = (
          Array(encode_segments(search.segments)) +
          Array(encode_pax(search)) +
          Array(encode_cabin(search.cabin))
        ).compact.join(SEGMENT_SEPARATOR)
        true
      end

      def encode_segments(segments)
        segments.each_with_index.map do |segment, idx|
          prev_segment = segments[idx - 1] if idx > 0
          tokens = [segment.from_iata, segment.to_iata]

          # специальный случай для round trip, не пропускаем точки назначения
          # на втором сегменте
          idx == 1 and segments.size == 2 and
            prev_segment.from_iata == segment.to_iata and
            prev_segment.to_iata == segment.from_iata and
              tokens = []

          tokens << encode_date(segment.date_as_date)
          tokens.join(INTERNAL_SEPARATOR)
        end
      end

      def encode_date(date)
        # Sep1, no spaces
        date.strftime('%e%b').tr(' ','')
      end

      def encode_cabin(cabin)
        case cabin
        when 'C'
          'business'
        when 'F'
          'first'
        end
      end

      def encode_pax(search)
        return if search.adults == 1 && search.children == 0 && search.infants == 0
        result = []
        result << "adult" if search.adults == 1
        result << "#{search.adults}adults" if search.adults > 1
        result << "child" if search.children == 1
        result << "#{search.children}children" if search.children > 1
        result << "infant" if search.infants == 1
        result << "#{search.infants}infants" if search.infants > 1
        result.join(INTERNAL_SEPARATOR)
      end
    end
  end
end


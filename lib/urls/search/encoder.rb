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
        @url = (
          Array(encode_segments(search.segments)) +
          Array(encode_cabin(search.cabin)) +
          Array(encode_pax(search))
        ).compact.join(Conf.search_urls.segment_separator)
        true
      end

      # FIXME возможен разорванный маршрут, где кодировщик уберет только to_iata
      def encode_segments(segments)
        segments.each_with_index.map do |segment, idx|
          prev_segment = segments[idx - 1] if idx > 0
          tokens = []
          # временно конфигурируемо
          if idx == 0 || ((idx == 1 && !Conf.search_urls.short_rt) || (idx > 1 && !Conf.search_urls.short_chains)) && prev_segment.to_iata != segment.from_iata
            tokens << segment.from_iata
          end
          unless Conf.search_urls.short_rt && idx == 1 && prev_segment.from_iata == segment.to_iata
            tokens << segment.to_iata
          end
          tokens << encode_date(segment.date_as_date)
          tokens.join(Conf.search_urls.internal_separator)
        end
      end

      def encode_date(date)
        # Sep1, no spaces
        date.strftime('%b%e').tr(' ','')
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
        result << "adt" if search.adults == 1
        result << "#{search.adults}adt" if search.adults > 1
        result << "chd" if search.children == 1
        result << "#{search.children}chd" if search.children > 1
        result << "inf" if search.infants == 1
        result << "#{search.infants}inf" if search.infants > 1
        result
      end
    end
  end
end


# encoding: utf-8

require 'urls/search'

module Urls
  module Search

    module Decodable
      def self.included(base)
        base.extend(Classmethods)
      end

      module Classmethods
        def from_code(code)
          # затычка для старых урлов
          return load_from_cache(code) if code.size == 6
          decoder = Decoder.new(code)
          if decoder.valid?
            decoded = decoder.decoded
            PricerForm.new(
              adults: decoded.adults,
              children: decoded.children,
              infants: decoded.infants,
              cabin: decoded.cabin,
              segments: decoded.segments
            )
          else
            nil
          end
        end
      end
    end

    class Decoder
      attr_reader :decoded

      CHECKABLE = %w(adults children infants)
      FILLER = Urls::Search::FILLER_CHARACTER
      CABINS = %W{Y M B C F E W #{FILLER}}
      SEGMENT_SIZE = 11
      # основная валидация происходит здесь
      URL_REGEX = /^
        (?<cabin>\w)
        (?<adults>\d)
        (?<children>\d)
        (?<infants>\d)
        (?<segments>(?:[\p{Word}#{FILLER}]{#{SEGMENT_SIZE}}){1,6})$ #\p{Word} матчит и юникодные символы - нужно для сирены
      /xu
      # явно проверяем наличие филлера третьим символом
      IATA_REGEX = /(?:[A-ZА-Я]{2}#{FILLER})|(?:[A-ZА-Я]{3})/
      SEGMENT_REGEX = /
        (?<from_iata>#{IATA_REGEX})
        (?<to_iata>#{IATA_REGEX})
        (?<date>(?:\d{2}\w{3}))
      /xu

      def initialize(url)
        @decoded = nil
        @valid = parse(url)
      end

      def valid?
        @valid
      end

      CHECKABLE.each do |subject|
        class_eval <<-METHOD, __FILE__, __LINE__ + 1
          def #{subject}?
            @decoded.#{subject} > 0
          end
        METHOD
      end

      private

      def parse(url)
        if r = URL_REGEX.match(::Unicode::upcase(url))
          @decoded = PricerForm.new(
            adults: r[:adults].to_i,
            children: r[:children].to_i,
            infants: r[:infants].to_i,
            cabin: check_cabin(r[:cabin]),
            segments: parse_segments(r[:segments])
          )
          true
        else
          false
        end
      rescue => message
        return false
      end

      def parse_segments(coded)
        total_segments = coded.size / SEGMENT_SIZE
        raw_segments = coded.scan(SEGMENT_REGEX)
        raise "not all segments are valid" unless total_segments == raw_segments.size

        segments = {}

        raw_segments.each_with_index do |match, index|
          segments[index.to_s] = {
            from: decode_iata(match.first),
            to: decode_iata(match.second),
            date: decode_date(match.last)
          }

        end
        segments
      end

      def decode_iata(coded_iata)
        # филлер после проверки регекспом может остаться в конце iata
        coded_iata.delete! FILLER
        coded_iata
      end

      def decode_date(coded_date)
        d = Date.parse(coded_date)
        d = d < Date.today ? d.next_year : d
        d.strftime('%d%m%y')
      end

      def check_cabin(code)
        unless CABINS.include?(code)
          raise "cabin code should be one of [#{CABINS.join(' ' )}] instead of #{code}"
        end
        code
      end

    end
  end
end


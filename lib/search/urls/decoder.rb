# encoding: utf-8

require 'search/urls'

module Search
  module Urls

    class ParserError < Exception
    end

    class Decoder
      attr_reader :decoded

      def initialize(url)
        @decoded = nil
        @valid = parse(url)
      end

      def valid?
        @valid
      end

      private

      def parse(url)

        segments = []
        location_stack = []
        args = {}

        # пока забью на сирену, кириллица тоже разделитель.
        url.split(/[^A-Za-z0-9]+/).each do |token|

          case token

          # пришла дата, делаем сегмент из предыдущих локаций
          when /^(\d\d?)?(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)(\d\d?)?$/i
            date = decode_date(token)

            from, to = location_stack
            if to.nil?
              raise ParserError, "first segment can't be shortened" if segments.empty?
              # указан только "туда"
              from, to = segments.last[:to], from
              # не указано ничего, roundtrip
              to = segments.last[:from] if to.nil?
            end
            location_stack = []
            segments << AviaSearchSegment.new(from: from, to: to, date: date)

          # классы
          when /^business$/i
            args[:cabin] = 'C'
          when /^first$/i
            args[:cabin] = 'F'

          when /^(\d*)(adt|adults?)$/i
            args[:adults] = $1.presence || 1
          when /^(\d*)(chd|child|children)$/i
            args[:children] = $1.presence || 1
          when /^(\d*)(inf|infants?)$/i
            args[:infants] = $1.presence || 1

          # все остальное считаем пунктами назначения
          else
            location_stack.push token
            raise ParserError, "unknown token or dangling IATA #{token.inspect}" if location_stack.size > 2
          end
        end

        unless location_stack.empty?
          raise ParserError, "unknown token or missing date for IATA #{location_stack.inspect}"
        end

        @decoded = AviaSearch.new( args.merge( segments: segments ) )
        true
      # штатные случаи рейзятся с ParserError, нештатные - без,
      # в любом случае перехватываем, чтобы не свалиться и переправить юзера на главную
      rescue Exception
        ## для того чтобы логгировать
        #with_warning
        return false
      end

      def decode_date(coded_date)
        d = Date.parse(coded_date)
        d = d < Date.today ? d.next_year : d
        d
      end
    end
  end
end


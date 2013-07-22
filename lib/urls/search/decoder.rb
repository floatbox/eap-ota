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
          decoder.decoded if decoder.valid?
        end
      end
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
        adults = 0
        children = 0
        infants = 0
        cabin = 'Y'

        location_stack = []

        # пока забью на сирену, кириллица тоже разделитель.
        url.split(/[^A-Za-z0-9]+/).each do |token|

          case token

          # пришла дата, делаем сегмент из предыдущих локаций
          when /^(\d\d?)?(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)(\d\d?)?$/i
            date = decode_date(token)
            from, to = location_stack
            if to.nil?
              raise "first segment can't be shortened" if segments.empty?
              # указан только "туда"
              from, to = segments.last[:to], from
              # не указано ничего, roundtrip
              to = segments.last[:from] if to.nil?
            end
            location_stack = []
            segments << { from: from, to: to, date: date }

          # классы
          when /^business$/i
            cabin = 'C'
          when /^first$/i
            cabin = 'F'

          when /^(\d*)(adt|adults?)$/i
            adults   = ($1.presence || 1).to_i
          when /^(\d*)(chd|child|children)$/i
            children = ($1.presence || 1).to_i
          when /^(\d*)(inf|infants?)$/i
            infants  = ($1.presence || 1).to_i

          # все остальное считаем пунктами назначения
          else
            location_stack.push token
            raise "unknown token or dangling IATA #{token.inspect}" if location_stack.size > 2
          end
        end

        raise "unknown token or missing date for IATA #{location_stack.inspect}" unless location_stack.empty?

        # если пассажиры вообще не указаны - это один взрослый
        adults = 1 if [adults, children, infants] == [0, 0, 0]

        @decoded = PricerForm.new(
          adults: adults,
          children: children,
          infants: infants,
          cabin: cabin,
          segments: paramify_array(segments)
        )
      end

      def paramify_array(array)
        Hash[ array.each_with_index.map { |record, index| [index.to_s, record] } ]
      end

      def decode_date(coded_date)
        d = Date.parse(coded_date)
        d = d < Date.today ? d.next_year : d
        d.strftime('%d%m%y')
      end

    end
  end
end


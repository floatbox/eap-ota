module Parsers
  class Alfabank

    def initialize(doc, filename)
      @filename = filename
      @doc = doc.dup.force_encoding('windows-1251').encode('utf-8')
    end

    MAPPING = {
      date: 0..7,
      time: 10..14,
      # wtf1: 18..28,
      # wtf2: 30..34,
      pan: 37..54,
      amount: 77..91,
      commission: 100..116,
      # wtf6: 117..122,
      # wtf7: 124..127,
      # wtf8: 132..136,
      # wtf9: 140..151,
      # wtf10: 155..166,
      # wtf11: 172..175,
      # wtf12: 204..217,
      # wtf13: 228..243
    }

    def parse
      @rows = []
      @doc.each_line do |line|
        #если кончился мусор и пошли наши столбцы, начинаются на дату, всегда
        next unless line.match(/^(0[1-9]|[12][0-9]|3[01])[-.](0[1-9]|1[012])[-.]\d\d/)
        @rows << parse_line(line)
      end
      @rows
    end

    def parse_line(line)
      row = {}
      MAPPING.each do |key, range|
        row[key] = line[range].to_s.strip
      end
      row[:datetime] = parse_date(row[:date], row[:time])
      row
    end

    def display
      @doc
    end

    private

    def parse_date(date, time)
      dd, mm, yy = date.split(/\D/).map(&:to_i)
      hh, ss = time.split(':').map(&:to_i)
      DateTime.new(2000+yy, mm, dd, hh, ss)
    end

  end
end

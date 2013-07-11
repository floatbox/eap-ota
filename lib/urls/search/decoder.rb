# encoding: utf-8

module Urls::Search

  class Decoder
    attr_reader :decoded

    CHECKABLE = %w(adults children infants)
    FILLER = Urls::Search::FILLER_CHARACTER
    CABINS = %W{Y M B C F E W #{FILLER}}
    SEGMENT_SIZE = 13
    # основная валидация происходит здесь
    URL_REGEX = /^
      (?<cabin>\w)
      (?<adults>\d)
      (?<children>\d)
      (?<infants>\d)
      (?<segments>(?:[\p{Word}#{FILLER}]{#{SEGMENT_SIZE}}){1,6})$ #\p{Word} матчит и юникодные символы - нужно для сирены
    /xu
    # явно проверяем наличие филлера третим символом
    IATA_REGEX = /(?:[A-ZА-Я]{2}#{FILLER})|(?:[A-ZА-Я]{3})/
    SEGMENT_REGEX = /
      (?<from_iata>#{IATA_REGEX})
      (?<to_iata>#{IATA_REGEX})
      (?<date>(?:\d{2}\w{3}\d{2}))
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
        @decoded = OpenStruct.new(
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
      # TODO убрать puts
      $stdout.puts "PARSE ERROR: #{message}"
      return false
    end

    def check_cabin(code)
      unless CABINS.include?(code)
        raise "cabin code should be one of [#{CABINS.join(' ' )}] instead of #{code}"
      end
      code
    end

    def parse_segments(raw_segments)
      total_segments = raw_segments.size / SEGMENT_SIZE
      segments = raw_segments.scan(SEGMENT_REGEX)
      raise "not all segments are valid" unless total_segments == segments.size
      segments.map do |match|
        OpenStruct.new(
          from_iata: match[0],
          to_iata: match[1],
          flight_date: Date.parse(match[2])
        )
      end
    end

  end
end


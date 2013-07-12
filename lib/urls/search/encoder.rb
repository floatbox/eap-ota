# encoding: utf-8

module Urls::Search

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
      cabin = search.cabin.to_s.upcase
      adults = search.adults.to_s.upcase
      children = search.children.to_s.upcase
      infants = search.infants.to_s.upcase
      segments = encode_segments(search.segments)

      @url = cabin + adults + children + infants + segments
      true
    end

    def encode_segments(segments)
      encoded_segments = segments.map do |segment|
        encode_iata(segment.from) + encode_iata(segment.to) + encode_date(segment.date)
      end
      encoded_segments.join
    end

    def encode_date(date)
      date.strftime('%d%b').upcase
    end

    def encode_iata(iata)
      if iata.size == 2
        iata + Urls::Search::FILLER_CHARACTER
      else
        iata
      end
    end
  end
end


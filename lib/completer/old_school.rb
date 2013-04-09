# encoding: utf-8
require 'active_support'
require 'active_support/core_ext/string/multibyte'
require 'completer/normalizer'
module Completer
  class OldSchool

    include Normalizer

    attr_reader :records, :index

    def initialize
      clear
    end

    def object_from_string(name)
      scan_eq(name) do |record|
        return record.original_object
      end
      nil
    end

    def complete(string, opts={})
      data = []
      string = string.mb_chars
      limit = opts[:limit] && opts[:limit].to_i
      scan(string) do |record|
        data << record
        break if data.size == limit
      end
      # убираем "Москва, в Москву", потом убираем одноименные объекты,
      # все равно только первый найдется object_from_string-ом
      data.uniq_by(&:signature).uniq_by(&:name).map(&:entity)
    end

    def scan(prefix)
      normalized_prefix = normalize(prefix)
      return if normalized_prefix.blank? || !@index[normalized_prefix[0].to_s]
      @index[normalized_prefix[0].to_s].each do |record|
        yield(record) if record.prenormalized_matches?(normalized_prefix)
      end
    end

    def scan_eq(word)
      normalized_word = normalize(word)
      return if normalized_word.blank?
      (@index[normalized_word[0].to_s] || []).each do |record|
        yield(record) if record.prenormalized_eq?(normalized_word)
      end
    end

    def clear
      @records = []
      @index = {}
    end

    def add(args)
      rec = Record.wrap(args)
      @records << rec
      rec.to_match_index_letters.each {|letter| @index[letter] ||= []; @index[letter] << rec }
    end

    class Record

      include Normalizer

      def self.wrap(args)
        args.is_a?(Record) ? args : Record.new(args)
      end

      def initialize(attrs)
        if attrs.is_a? String
          attrs = {:name => attrs}
        end
        @name = attrs[:name]
        @code = attrs[:code].presence
        @type = attrs[:type]
        @hint = attrs[:hint]
        update_to_match(attrs[:aliases])
      end

      attr_accessor :type, :name, :code, :to_match, :hint

      def entity
        {
          code: code,
          type: type,
          name: name,
          hint: hint,
          # legacy
          iata: code,
          area: hint
        }
      end

      def signature
        {
          type: type,
          code: code
        }
      end

      def update_to_match(aliases)
        words = [name, aliases].flatten.delete_if(&:blank?).uniq
        @to_match = words.map {|word| normalize(word)}
      end

      # normalized first letters (for now)
      def to_match_index_letters
        (@to_match + Array(code.presence && normalize(code))).delete_if(&:blank?).map{ |word| word[0].to_s }.uniq
      end

      def matches?(prefix)
        prenormalized_matches?(normalize(prefix))
      end

      def original_object
        type.classify.constantize[code]
      end

      def prenormalized_matches?(normalized_prefix)
        if normalized_prefix.length == 3
          # full match of IATA for countries
          possible_code = normalized_prefix.upcase
        end

        to_match.any? do |str|
          str.start_with?(normalized_prefix)
        end || possible_code && possible_code == code
      end

      def prenormalized_eq?(normalized_word)
        to_match.any? do |str|
          str == normalized_word
        end || (code && code.downcase == normalized_word)
      end
    end

  end
end

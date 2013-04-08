# encoding: utf-8
require 'active_support'
require 'active_support/core_ext/string/multibyte'
require 'every'
require 'russian'
require 'completer/normalizer'
require 'completer/qwerty'

class Completer
  attr_reader :records, :index

  include Normalizer

  def self.preload!
    cached_or_new
  end

  def self.cached_or_new
    @completer ||= Completer.load
  end

  def initialize
    clear
    read_all
  end

  MARSHAL_FILE = 'tmp/completer.dat'
  def dump(filepath=MARSHAL_FILE)
    Rails.logger.debug "Completer: dumping to cache #{filepath}"
    open(filepath, 'w') do |f|
      Marshal.dump(self, f)
    end
  end

  def self.regen
    new.dump
  end

  def self.load(filepath=MARSHAL_FILE)
    Rails.logger.debug "Completer: loading from cache #{filepath}"
    Marshal.load(open(filepath))
  end

  class << self
    delegate :complete, :dump, :object_from_string, :to => :cached_or_new
  end

  def object_from_string(name)
    scan_eq(name) do |record|
      return record.original_object
    end
    nil
  end

  def complete(string, position=nil, opts={})
    data = []
    string = string.mb_chars
    position = string.size
    limit = opts[:limit] && opts[:limit].to_i
    scan(string) do |record|
      hl = normalize(string).to_s
      data << {
        :insert => record.word,
        :start => 0,
        :end => position,
        :name => record.name,
        :hl => hl,
        :entity => record.entity
      }
      break if data.size == limit
    end

    if data.blank? && (opts.delete(:jcuken) != false)
      complete(Qwerty.jcuken(string), position, opts.merge(:jcuken => false))
    else
      # вроде бы не очень эффективно выкидываем одинаковые объекты под разными названиями.
      # а потом вроде бы выкидываем аэропорты, которые называются так же как города.
      data.uniq_by {|e| e[:entity].except(:name) }.uniq_by {|e| e[:name]}
    end
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

  def read_all
    read_important_objects
    read_countries
    read_cities
    read_airports
  end

  # dictionaries from database
  def read_important_objects
    ( Country.important.all +
      City.important.with_country.all +
      Airport.important.with_country.all
    ).sort_by(&:importance).reverse.each do |c|
      case c
      when Country
        add_country(c)
      when City
        add_city(c)
      when Airport
        add_airport(c)
      end
    end
  end

  def add_country(c)
    synonyms = []
    synonyms << c.name_en unless c.name_en == c.name
    synonyms += c.synonyms
    synonyms.delete_if &:blank?
    add(:name => c.name, :type => 'country', :code => c.iata, :aliases => synonyms, :hint => c.continent_part_ru)
    add(:name => c.case_to, :type => 'country', :code => c.iata, :hint => c.continent_part_ru)
  end


  def read_countries
    Country.not_important.each do |c|
      add_country(c)
    end
  end

  def add_city(c)
    synonyms = []
    synonyms << c.name_en unless c.name_en == c.name
    synonyms += c.synonyms
    synonyms.delete_if &:blank?
    add(:name => c.name, :type => 'city', :code => c.iata, :aliases => synonyms, :hint => c.country.name, :info => "Город #{c.name} #{c.country.case_in}")
    add(:name => c.case_to, :type => 'city', :code => c.iata, :hint => c.country.name, :info => "Город #{c.name} #{c.country.case_in}")
  end

  def read_cities
    City.not_important.with_country.each do |c|
      add_city(c)
    end
  end

  def add_airport(c)
    unless c.equal_to_city
      synonyms = []
      synonyms << c.name_en unless c.name_en == c.name
      synonyms += c.synonyms
      synonyms.delete_if &:blank?
      add(:name => c.name, :type => 'airport', :code => c.iata, :aliases => synonyms, :hint => c.city.name,  :info => "Аэропорт #{c.name} #{c.city.case_in}, #{c.city.country.name}")
      add(:name => c.case_to, :type => 'airport', :code => c.iata, :hint => c.city.name,  :info => "Аэропорт #{c.name} #{c.city.case_in}, #{c.city.country.name}")
    end
  end

  def read_airports
    Airport.not_important.with_country.each do |c|
      add_airport(c)
    end
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
      @word = attrs[:word] || @name
      @code = attrs[:code]
      @info = attrs[:info]
      @hint = attrs[:hint]
      @hidden_info = attrs[:hidden_info]
      @code = nil if @code == ''
      @aliases = attrs[:aliases].presence || []
      @aliases = @aliases.split(':').every.strip if @aliases.is_a?(String)
      @type = (attrs[:type] || 'city').to_s
      update_to_match
    end

    attr_accessor :word, :type, :name, :code, :aliases, :to_match, :info, :hint, :hidden_info

    def entity
      { :iata => code, :type => type, :name => name, :info => info, :hint => hint, :hidden_info => hidden_info }.delete_if {|key, value| value.nil? }
    end

    def update_to_match
      @to_match = ([word] + aliases).compact.map {|word| normalize(word)}
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


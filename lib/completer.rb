# encoding: utf-8
require 'active_support'
require 'active_support/core_ext/string/multibyte'
require 'every'
require 'russian'

class Completer
  attr_reader :updated_at
  attr_reader :records, :index

  module Normalizer
    # какая-то фигня тут творится в 1.8.7
    NONWORD = (RUBY_VERSION < '1.9.0') ? /\W+/ : /[^[:alnum:]]+/
    def normalize(word)
      word.mb_chars.downcase.gsub(NONWORD, ' ').strip
    end
  end

  include Normalizer

  def self.cached_or_new
    # "временно" выключил автозагрузку свежего комплитера
    if !@completer # || (cache_loaded_at < cache_updated_at)
      @completer = Completer.load rescue nil
    end
    # временно выключил автоматическую перегенерацию
    if !@completer # || @completer.outdated?
      @completer = Completer.new
      @completer.dump
      @cache_loaded_at = Time.now
    end
    @completer
  end

  def initialize(filename_or_words=nil)
    clear
    if filename_or_words.is_a? String
      read_csv(filename_or_words)
    elsif filename_or_words.is_a? Array
      read_array(filename_or_words)
    else
      read_all
    end
  end

  MARSHAL_FILE = 'tmp/completer.dat'
  def dump
    open(MARSHAL_FILE, 'w') do |f|
      Marshal.dump(self, f)
    end
    Rails.logger.debug "Completer: dumped to cache"
  end

  def self.regen
    new.dump
  end

  def self.cache_loaded_at
    @cache_loaded_at
  end

  def self.cache_updated_at
    File.mtime(MARSHAL_FILE)
  end

  def self.load
    @completer = Marshal.load(open(MARSHAL_FILE))
    @cache_loaded_at = Time.now
    Rails.logger.debug "Completer: loaded from cache"
    @completer
  end

  class << self
    delegate :complete, :dump, :iata_from_name, :record_from_string, :to => :cached_or_new
  end


  def iata_from_name(name)
    # FIXME перенести отсюда в фильтр например
    scan_eq(name) do |record|
      return record.code if %W(city airport country region).include? record.type
    end
    nil
  end

  # FIXME объединить с iata_from_name
  def record_from_string(name, types=['city', 'airport', 'country', 'region'])
    scan_eq(name) do |record|
      return record if types.include? record.type
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
      } unless record.entity[:type] == 'airport' && record.entity[:iata].downcase == string.downcase && data.find{|d| d[:entity][:type] == 'city' && d[:entity][:iata] == record.entity[:iata]} #fixes #249
      break if data.size == limit
    end

    if data.blank? && (opts.delete(:jcuken) != false)
      complete(Qwerty.jcuken(string), position, opts.merge(:jcuken => false))
    else
      data = uniq_by(data){|e| e[:entity].merge({:name => nil})}
      uniq_by(data){|e| e[:name]}
    end
  end

  def uniq_by(array, &blk)
    transforms = {}
    array.select do |el|
      t = blk[el]
      should_keep = !transforms[t]
      transforms[t] = true
      should_keep
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
    # так было бы вернее, но default_proc нельзя Marshal.dump
    # @index = Hash.new {|hash, key| hash[key] = [] }
    @index = {}
  end

  def add(args)
    rec = (args.is_a?(Record) ? args : Record.new(args))
    @records << rec
    rec.to_match_index_letters.each {|letter| @index[letter] ||= []; @index[letter] << rec }
  end

  def read_csv(filename)
    # TODO use real CSV Reader
    open(filename).each_line do |l|
      l.chomp
      next if l =~ /^\s*$/
      next if l =~ /^#/

      attrs = Hash[ [:name, :type, :code, :aliases].zip( l.split(';').every.strip) ]

      add( attrs )
    end
  end

  def read_all
    read_important_objects
    read_countries
    read_cities
    read_airports
    # FIXME выключил, пока не исправим баг с распознаванием регионов
    #read_regions
    @updated_at = Time.now
  end

  def read_array(names)
    names.each {|name| add(name)}
  end

  # generated dictionaries


  # dictionaries from database
  def read_important_objects
    ( Country.important.all +
      City.important.with_country.all +
      Airport.important.with_country.all +
      Region.important.with_country.all
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

  def add_region(c)
    synonyms = []
    synonyms << c.name_en unless c.name_en == c.name
    synonyms += c.synonyms
    synonyms.delete_if &:blank?
    add(:name => c.name, :type => 'region', :aliases => synonyms, :hint => c.country.name, :info => "#{c.region_type.mb_chars.capitalize} #{c.name} #{c.country.case_in}")
    add(:name => c.case_to, :type => 'region', :hint => c.country.name, :info => "#{c.region_type.mb_chars.capitalize} #{c.name} #{c.country.case_in}")
  end

  def read_regions
    Region.not_important.with_country.each do |c|
      add_region(c)
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

  def outdated?
    @updated_at && (
      @updated_at < [Carrier, Airplane, Airport, City, Country, GeoTag].every.maximum(:updated_at).max ||
      @updated_at.to_date < Date.today
    )
  end

  class Record

    include Normalizer

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
      (Kernel.const_get(type.camelize))[code] if code.present? && (['airport', 'city', 'country'].include? type)
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

  module Qwerty
    QWERTY = ('qwertyuiop[]' + 'QWERTYUIOP{}' +
      'asdfghjkl;\'' + 'ASDFGHJKL:"' +
      'zxcvbnm,./' + 'ZXCVBNM<>?')
    JCUKEN = ('йцукенгшщзхъ' + 'ЙЦУКЕНГШЩЗХЪ' +
      'фывапролджэ' + 'ФЫВАПРОЛДЖЭ' +
      'ячсмитьбю.' + 'ЯЧСМИТЬБЮ,').mb_chars
    QJ_MAP = Hash[QWERTY.chars.zip(JCUKEN.chars)]


    module_function

    def jcuken(s)
      s.mb_chars.chars.map {|c| QJ_MAP[c] || c }.join.mb_chars
    end

  end

end


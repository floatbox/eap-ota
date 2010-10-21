# -*- coding: utf-8 -*-
require 'active_support'
require 'active_support/core_ext/string/multibyte'
require 'traviata/active_record_ext'#почему то из инициалайзера не подключается, вылезает undefined method `has_cases_for'
require 'every'
require 'russian'
$KCODE = 'u'

class Completer
  attr_reader :updated_at
  attr_reader :records, :index

  module Normalizer
    def normalize(word)
      word.mb_chars.downcase.gsub(/\W+/, ' ').strip
    end
  end

  include Normalizer

  def self.new_or_cached
    if !@completer || @completer.outdated?
      @completer = (['cucumber', 'test'].include? RAILS_ENV) ? Completer.load : Completer.new
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
  end

  def self.load
    @completer = Marshal.load(open(MARSHAL_FILE))
    @completer
  end

  class << self
    delegate :complete, :dump, :iata_from_name, :to => :new_or_cached
  end


  def iata_from_name(name)
    # FIXME перенести отсюда в фильтр например
    scan_eq(name) do |record|
      return record.code if record.type == 'city' || record.type == 'airport' || record.type == 'country'
    end
    nil
  end

  def complete(string, position=nil, opts={})
    string = string.mb_chars
    position = (position || string.size).to_i
    data = []
    limit = opts[:limit] && opts[:limit].to_i

    unless string.empty?
      prefix = string[0, position]

      # конец слова, на котором находится курсор
      postfix = string[position..-1]

      end_poses = []
      for word_ending_pattern in [ /^\S*/, /^\S*\s+\S+/, /^\S*\s+\S+\s+\S+/]
        if m = postfix.match(word_ending_pattern)
          end_poses << (position + m[0].mb_chars.length)
        end
      end

      leftmost_start_pos = nil
      for word_beginning_pattern in [ /\S+\s+\S+\s+\S+\s*$/, /\S+\s+\S+\s*$/, /\S+\s*$/ ]
        if m = prefix.match(word_beginning_pattern)
          word_part = m[0].mb_chars

          start_pos = position - word_part.length

          scan(word_part) do |record|

            leftmost_start_pos ||= start_pos

            end_pos = end_poses.reverse.detect {|pos|
              record.matches?(string[start_pos...pos])
            } || end_poses[0]

            hl = normalize(word_part).to_s
            data << {
              :insert => record.word,
              :start => leftmost_start_pos,
              :end => end_pos,
              :name => record.name,
              :hl => hl,
              :entity => record.entity
            } unless record.entity[:type] == 'airport' && record.entity[:iata].downcase == word_part.to_s.downcase && data.find{|d| d[:entity][:type] == 'city' && d[:entity][:iata] == record.entity[:iata]} #fixes #249
            break if data.size == limit
          end
        end
      end
    end

    if data.blank? && (opts.delete(:jcuken) != false)
      complete(Qwerty.jcuken(string), position, opts.merge(:jcuken => false))
    else
      data
    end
  end

  def scan(prefix)
    normalized_prefix = normalize(prefix)
    return if normalized_prefix.blank?
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
    #read_airlines
    #read_airplanes
    read_airports
    #read_geotags

    #read_dates
    #read_months
    #read_passengers
    #read_comforts
    #read_airplane_families

    @updated_at = Time.now
  end

  def read_array(names)
    names.each {|name| add(name)}
  end

  # generated dictionaries

  WEEKDAY_NAMES = ['в воскресенье', 'в понедельник', 'во вторник', 'в среду', 'в четверг', 'в пятницу', 'в субботу']
  def read_dates
    days = (1..7).collect {|cnt| date = cnt.days.since(Date.today); [ WEEKDAY_NAMES[date.wday], date] }
    days << ['сегодня', Date.today]
    days << ['завтра', 1.day.from_now.to_date]
    days << ['послезавтра', 2.days.from_now.to_date]

    for name, date in days
      add(:name => name, :type => 'date', :hint => Russian.strftime(date, '%e %B'), :info => Russian.strftime(date, '%A, %e %B %Y года'))
    end
  end

  # FIXME пока не возвращает числа
  MONTHS = %W(январь февраль март апрель май июнь июль август сентябрь октябрь ноябрь декабрь)
  def read_months
    MONTHS.each do |month|
      add(:name => month, :type => 'date')
    end
  end

  PAX = 'вдвоем', 'втроем', 'вчетвером', 'впятером', 'с ребенком', 'c подругой'
  def read_passengers
    PAX.each do |pax|
      add(:name => pax, :type => 'people')
    end
  end

  def read_comforts
    ['бизнес-класс', 'эконом-класс'].each do |comfort|
      add(:name => comfort, :type => 'comfort')
    end
  end

  # аргх
  def read_airplane_families
    add(:name => 'на Boeing', :aliases => ['Boeing', 'Боинг', 'на Боинге'], :type => 'aircraft')
    add(:name => 'на Airbus', :aliases => ['Airbus', 'Аирбас', 'Айрбас', 'Эйрбас', 'Эирбас', 'Аэробус'], :type => 'aircraft')
  end

  # dictionaries from database
  def read_important_objects
    cnd = {:conditions => 'importance > 0'}
    (Country.all(cnd) + 
     City.all(cnd.merge({:include => :country})) + 
     Airport.all(cnd.merge(:include => {:city => :country}))).sort_by(&:importance).reverse.each do |c|
      if c.class == Country
        add_county(c)
      elsif c.class == City
        add_city(c)
      elsif c.class == Airport
        add_airport(c)
      end
    end
  end
  
  def add_county(c)
    synonyms = []
    synonyms << c.name_en unless c.name_en == c.name
    synonyms += c.synonyms
    synonyms.delete_if &:blank?
    add(:name => c.name, :type => c.kind, :code => c.iata, :aliases => synonyms, :hint => c.continent_part_ru)
  end
  
  
  def read_countries
    Country.all(:conditions => 'importance = 0').each do |c|
      add_county(c)
    end
  end

  def add_city(c)
    synonyms = []
    synonyms << c.name_en unless c.name_en == c.name
    synonyms += c.synonyms
    synonyms.delete_if &:blank?
    add(:name => c.name, :type => c.kind, :code => c.iata, :aliases => synonyms, :hint => c.country.name, :info => "Город #{c.name} #{c.country.proper_in}")
  end
  
  def read_cities
    City.all(:include => :country, :conditions => 'importance = 0').each do |c|
      add_city(c)
    end
  end

  def read_airlines
    Airline.all.each do |c|
      synonyms = []
      synonyms << c.short_name unless c.short_name == c.name
      synonyms.delete_if &:blank?
      add(:name => c.name, :type => c.kind, :code => c.iata, :aliases => synonyms)
    end
  end

  def read_airplanes
    Airplane.all.each do |c|
      synonyms = []
      synonyms << c.name_ru unless c.name_ru == c.name
      synonyms.delete_if &:blank?
      add(:name => c.name, :type => :aircraft, :code => c.iata, :aliases => synonyms)
    end
  end
  
  def add_airport(c)
    synonyms = []
    synonyms << c.name_en unless c.name_en == c.name
    synonyms += c.synonyms
    synonyms.delete_if &:blank?
    add(:name => c.name, :type => c.kind, :code => c.iata, :aliases => synonyms, :hint => c.city.name,  :info => "Аэропорт #{c.name} #{c.city.case_in}, #{c.city.country.name}") unless c.equal_to_city
  end
  
  def read_airports
    Airport.all(:include => {:city => :country}, :conditions => 'city_id is not null AND importance = 0').each do |c|
      add_airport(c)
    end
  end

  def read_geotags
    GeoTag.all.each do |c|
      add(:name => c.name, :type => c.kind, :aliases => c.synonyms)
    end
  end

  def outdated?
    @updated_at && (
      @updated_at < [Airline, Airplane, Airport, City, Country, GeoTag].every.maximum(:updated_at).max ||
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
      @code = nil if @code == ''
      @aliases = attrs[:aliases].presence || []
      @aliases = @aliases.split(':').every.strip if @aliases.is_a?(String)
      @type = (attrs[:type] || 'city').to_s
      update_to_match
    end

    attr_accessor :word, :type, :name, :code, :aliases, :to_match, :info, :hint

    def entity
      { :iata => code, :type => type, :name => name, :info => info, :hint => hint }.delete_if {|key, value| value.nil? }
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
    QJ_MAP = Hash[*QWERTY.chars.zip(JCUKEN.chars).flatten]


    module_function

    def jcuken(s)
      s.mb_chars.chars.map {|c| QJ_MAP[c] || c }.join.mb_chars
    end

  end

end


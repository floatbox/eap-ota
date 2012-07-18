# encoding: utf-8
require 'active_support'
require 'active_support/core_ext/string/multibyte'
require 'traviata/active_record_ext'#почему то из инициалайзера не подключается, вылезает undefined method `has_cases_for'
require 'every'
require 'russian'
$KCODE = 'UTF8' if RUBY_VERSION < '1.9.0'

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
    if !@completer || (cache_loaded_at < cache_updated_at)
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
    string = string.mb_chars
    position = (position || string.size).to_i
    position = [position, string.size].min
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
    #read_carriers
    #read_airplanes
    read_airports
    # FIXME выключил, пока не исправим баг с распознаванием регионов
    #read_regions
    #read_geotags

    #read_dates
    #read_months
    read_passengers
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
    days << ['завтра', Date.today + 1.day]
    days << ['послезавтра', Date.today + 2.days]
    days << ['через неделю', Date.today + 7.days]
    days << ['через месяц', Date.today + 1.month]

    for name, date in days
      add(:name => name, :type => 'date', :hint => Russian.strftime(date, '%e %B'), :info => Russian.strftime(date, '%A, %e %B %Y года'), :hidden_info => date.strftime('%d%m%y'))
    end
  end

  # FIXME пока не возвращает числа
  MONTHS = [['январь', ['января']],
             ['февраль', ['февраля']],
             ['март', ['марта']],
             ['апрель', ['апреля']],
             ['май', ['мая']],
             ['июнь', ['июня']],
             ['июль', ['июля']],
             ['август', ['августа']],
             ['сентябрь', ['сентября']],
             ['октябрь', ['октября']],
             ['ноябрь', ['ноября']],
             ['декабрь', ['декабря']]
           ]
  def read_months
    MONTHS.each_with_index do |month, i|
      add(:name => month[0], :type => 'date', :aliases => month[1], :hidden_info => (i+1) )
    end
  end

  PEOPLE = [['один', {:adults => 1}], ['вдвоем', {:adults => 2}], ['втроем', {:adults => 3}], ['вчетвером', {:adults => 4}], ['впятером', {:adults => 5}], ['с ребенком', {:children => 1}], ['с подругой', {:adults => 2}],['одна', {:adults => 1}], ['двое', {:adults => 2}], ['трое', {:adults => 3}], ['четверо', {:adults => 4}], ['пятеро', {:adults => 5}], ['с младенцем', {:infants => 1}]]
  def read_passengers
    PEOPLE.each do |pax, hidden_info|
      add(:name => pax, :type => 'people', :hidden_info => hidden_info)
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

  def read_carriers
    Carrier.all.each do |c|
      synonyms = []
      synonyms << c.short_name unless c.short_name == c.name
      synonyms.delete_if &:blank?
      add(:name => c.name, :type => 'carrier', :code => c.iata, :aliases => synonyms)
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

  def read_geotags
    GeoTag.all.each do |c|
      add(:name => c.name, :type => 'geo_tag', :aliases => c.synonyms)
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


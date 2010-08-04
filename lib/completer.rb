# -*- coding: utf-8 -*-
require 'active_support'
require 'active_support/core_ext/string/multibyte'
require 'traviata/active_record_ext'#почему то из инициалайзера не подключается, вылезает undefined method `has_cases_for'
require 'every'
require 'russian'
$KCODE = 'u'

class Completer
  attr_reader :updated_at

  module Normalizer
    def normalize(word)
      word.mb_chars.downcase.gsub(/\W+/, ' ').strip
    end
  end

  include Normalizer

  def self.new_or_cached
    if !@completer || @completer.outdated?
      @completer = Completer.new
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

  def iata_from_name(name)
    # FIXME перенести отсюда в фильтр например
    scan_eq(name) do |record|
      return record.code if record.type == 'city' || record.type == 'airport'
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
            }
            return data if data.size == limit
          end
        end
      end
    end
    return data
  end

  def scan(prefix)
    normalized_prefix = normalize(prefix)
    @records.each do |record|
      yield(record) if record.prenormalized_matches?(normalized_prefix)
    end
  end

  def scan_eq(word)
    normalized_word = normalize(word)
    @records.each do |record|
      yield(record) if record.prenormalized_eq?(normalized_word)
    end
  end

  def clear
    @records = []
  end

  def add(args)
    @records << (args.is_a?(Record) ? args : Record.new(args))
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
    read_countries
    read_cities
    read_airlines
    read_airplanes
    read_airports
    read_geotags

    read_dates
    read_months
    read_passengers
    read_comforts
    read_airplane_families

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
      add(:name => name, :type => 'date', :hint => Russian.strftime(date, '%e %b'), :info => Russian.strftime(date, '%A, %e %b %Y года'))
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

  def read_countries
    Country.all.each do |c|
      synonyms = []
      synonyms << c.name_en unless c.name_en == c.name
      synonyms += c.synonyms
      add(:name => c.name, :type => c.kind, :code => c.iata, :aliases => synonyms, :hint => c.continent_part_ru)
    end
  end

  def read_cities
    City.all(:include => :country).each do |c|
      synonyms = []
      synonyms << c.name_en unless c.name_en == c.name
      synonyms += c.synonyms
      add(:name => c.name, :type => c.kind, :code => c.iata, :aliases => synonyms, :hint => c.country.name, :info => "Город #{c.name} #{c.country.proper_in}")
    end
  end

  def read_airlines
    Airline.all.each do |c|
      synonyms = []
      synonyms << c.short_name unless c.short_name == c.name
      add(:name => c.name, :type => c.kind, :code => c.iata, :aliases => synonyms)
    end
  end

  def read_airplanes
    Airplane.all.each do |c|
      synonyms = []
      synonyms << c.name_ru unless c.name_ru == c.name || c.name_ru.blank?
      add(:name => c.name, :type => :aircraft, :code => c.iata, :aliases => synonyms)
    end
  end

  def read_airports
    Airport.all(:include => {:city => :country}, :conditions => 'city_id is not null').each do |c|
      synonyms = []
      synonyms << c.name_en unless c.name_en == c.name || c.name_en.blank?
      add(:name => c.name, :type => c.kind, :code => c.iata, :aliases => synonyms, :hint => c.city.name,  :info => "Аэропорт #{c.name} #{c.city.proper_in}, #{c.city.country.name}")
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
      { :iata => code, :type => type, :name => name, :info => info, :hint => hint }
    end

    def update_to_match
      @to_match = ([word] + aliases).compact.map {|word| normalize(word)}
    end

    def matches?(prefix)
      prenormalized_matches?(normalize(prefix))
    end

    def prenormalized_matches?(normalized_prefix)
      if normalized_prefix.length > 3
        layout_fixed_prefix = Qwerty.jcuken(normalized_prefix)
      end

      if normalized_prefix.length == 3
        # full match of IATA for countries
        possible_code = normalized_prefix.upcase
      end

      to_match.any? do |str|
        str.start_with?(normalized_prefix) ||
        layout_fixed_prefix && str.start_with?(layout_fixed_prefix)
      end || possible_code && possible_code == code
    end

    def prenormalized_eq?(normalized_word)
      to_match.any? do |str|
        str == normalized_word
      end || (code && code.downcase == normalized_word)
    end
  end

  require 'memoize'
  class Qwerty
    QWERTY = ('qwertyuiop[]' + '{}' +
      'asdfghjkl;\'' + ':"' +
      'zxcvbnm,.' + '<>')
    JCUKEN = ('йцукенгшщзхъ' + 'хъ' +
      'фывапролджэ' + 'жэ' +
      'ячсмитьбю' + 'бю').mb_chars
    QJ_MAP = Hash[*QWERTY.chars.zip(JCUKEN.chars).flatten]


    class << self
      def jcuken(s)
        s.mb_chars.chars.map {|c| QJ_MAP[c] || c }.join.mb_chars
      end
      Object.send :include, Memoize
      memoize :jcuken
    end
  end

end


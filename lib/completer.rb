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
      @completer = Completer.new('config/words_short.csv', true)
    end
    @completer
  end
  
  def initialize(filename_or_words, load_models = false)
    if filename_or_words.is_a? String
      if filename_or_words =~ /\.csv$/
        read_csv(filename_or_words)
      else
        read_plain(filename_or_words)
      end
    else
      read_array(filename_or_words)
    end
    if load_models
      read_from_models
    end
    create_base_records
  end
  
  def iata_from_name(name)
    result = nil
    scan(name) do |record|
      result ||= record.code if record.type == 'city' || record.type == 'airport'
    end
    result
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
              :entity => { :iata => record.code, :type => record.type, :name => record.name, :info => record.info, :hint => record.hint }
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

  def read_plain(filename)
    @records = []
    open(filename).each_line do |l|
      l.chomp
      next if l =~ /^\s*$/
      next if l =~ /^#/
      @records << Record.new(l)
    end
  end

  def read_csv(filename)
    # TODO use real CSV Reader
    @records = []
    open(filename).each_line do |l|
      l.chomp
      next if l =~ /^\s*$/
      next if l =~ /^#/

      attrs = Hash[ [:name, :type, :code, :aliases].zip( l.split(';').every.strip) ]

      @records << Record.new( attrs )
    end
  end

  def read_array(names)
    @records = names.map {|name| Record.new(name)}
  end
  
  def create_base_records
    days_on = ['в воскресенье', 'в понедельник', 'во вторник', 'в среду', 'в четверг', 'в пятницу', 'в субботу']
    for day in Date.today+1.day.. Date.today+7.days
      #@records << Record.new(:name => Russian.strftime(day, '%A').mb_chars.downcase.to_s, :type => 'date', :code => nil, :aliases => nil, :hint => Russian.strftime(day, '%e %b'), :info => day)
      @records << Record.new(:name => days_on[day.wday], :type => 'date', :code => nil, :aliases => nil, :hint => Russian.strftime(day, '%e %b'), :info => Russian.strftime(day, '%A, %e %b %Y года'))
    end
     @records << Record.new(:name => 'завтра', :type => 'date', :code => nil, :aliases => nil, :hint => Russian.strftime(Date.today+1.day, '%e %b'), :info => Russian.strftime(Date.today+1.day, '%завтра, %e %b %Y года'))
     @records << Record.new(:name => 'послезавтра', :type => 'date', :code => nil, :aliases => nil, :hint => Russian.strftime(Date.today+2.days, '%e %b'), :info => Russian.strftime(Date.today+2.days, 'послезавтра, %e %b %Y года'))
  end
  
  def read_from_models
    @records = [] unless @records
    Country.all.each do |c|
      synonyms = []
      synonyms << c.name_en unless c.name_en == c.name
      synonyms += c.synonym_list.split(/, /) unless c.synonym_list.blank?
      @records << Record.new(:name => c.name, :type => c.kind, :code => c.iata, :aliases => synonyms.join(':'))
    end
    City.all(:include => :country).each do |c|
      synonyms = []
      synonyms << c.name_en unless c.name_en == c.name
      synonyms += c.synonym_list.split(/, /) unless c.synonym_list.blank?
      @records << Record.new(:name => c.name, :type => c.kind, :code => c.iata, :aliases => synonyms.join(':'), :hint => c.country.name)
    end
    
    Airline.all.each do |c|
      synonyms = []
      synonyms << c.short_name unless c.short_name == c.name
      @records << Record.new(:name => c.name, :type => c.kind, :code => c.iata, :aliases => synonyms.join(':'))
    end
    Airplane.all.each do |c|
      synonyms = []
      synonyms << c.name_ru unless c.name_ru == c.name || c.name_ru.blank?
      @records << Record.new(:name => c.name, :type => :aircraft, :code => c.iata, :aliases => synonyms.join(':'))
    end
    Airport.all.each do |c|
      synonyms = []
      synonyms << c.name_en unless c.name_en == c.name || c.name_en.blank?
      @records << Record.new(:name => c.name, :type => c.kind, :code => c.iata, :aliases => synonyms.join(':'))
    end
    GeoTag.all.each do |c|
      synonyms = []
      synonyms += c.synonym_list.split(/, /) unless c.synonym_list.blank?
      @records << Record.new(:name => c.name, :type => c.kind, :aliases => synonyms.join(':'))
    end
    @updated_at = Time.now
  end
  
  def outdated?
    @updated_at && (@updated_at < [Airline, Airplane, Airport, City, Country, GeoTag].map{ |c| c.maximum(:updated_at) }.max) && (@updated_at.to_date < Date.today)
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
      @aliases = attrs[:aliases] ? attrs[:aliases].split(':').every.strip : []
      @type = attrs[:type] || 'city'
      update_to_match
    end

    attr_accessor :word, :type, :name, :code, :aliases, :to_match, :info, :hint

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

# encoding: utf-8
class PricerForm
  include Mongoid::Document
  include Mongoid::Timestamps
  #store_in :pricer_forms
  field :adults, :type => Integer, :default => 1
  field :children, :type => Integer, :default => 0
  field :infants, :type => Integer, :default => 0
  field :complex_to
  field :cabin
  field :query_key
  field :partner
  field :use_count, :type => Integer, :default => 1
  embeds_many :segments, :class_name => 'PricerForm::Segment'
  has_one :rambler_cache
  accepts_nested_attributes_for :segments
  delegate :to, :from, :from_iata, :to_iata, :to => 'segments.first'
  attr_reader :complex_to_parse_results

  # перенести в хелпер
  def self.convert_api_date(date_str)
    if date_str =~ /^20(\d\d)-(\d\d?)-(\d\d?)$/
      "%02d%02d%02d" % [$3, $2, $1].map(&:to_i)
    else
      date_str
    end
  end

  def self.simple(args)
    allowed_parameters = [:from, :to, :date1, :date2, :adults, :children, :infants, :seated_infants, :cabin, :partner]
    wrong_parameters = args.keys.map(&:to_sym) - allowed_parameters
    lack_of_parameters = [:from, :to, :date1] - args.keys.map(&:to_sym)
    unless wrong_parameters.empty?
      raise ArgumentError, "Unknown parameter(s) - \"#{wrong_parameters.join(', ')}\""
    end
    unless lack_of_parameters.empty?
      raise ArgumentError, "Lack of required parameter(s)  - \"#{lack_of_parameters.join(', ')}\""
    end
    return if !(Location[args[:from]] || Location[args[:to]])
    @from_as_object = Location[args[:from]]
    @to_as_object = Location[args[:to]]
    segments = {}
    segments["0"] = {:from => args[:from], :to => args[:to], :date => convert_api_date(args[:date1])}
    if args[:date2]
      segments["1"] = {:from => args[:to], :to => args[:from], :date => convert_api_date(args[:date2])}
    end
    adults = (args[:adults] || 1).to_i
    children = args[:children].to_i
    infants = args[:infants].to_i + args[:seated_infants].to_i
    cabin = args[:cabin]
    partner = args[:partner]

    new :segments => segments,
      :adults => adults, :children => children, :infants => infants, :cabin => cabin,
      :partner => partner
  end

  class Segment
    include Mongoid::Document
    embedded_in :form, :class_name => 'PricerForm'
    field :from
    field :to
    field :date

    attr_reader :to_as_object, :from_as_object
    validates_presence_of :from_as_object, :to_as_object, :date, :date_as_date
    validate :check_date

    def to_as_object_iata
      to_as_object.iata if to_as_object.respond_to? :iata
    end

    def from_as_object_iata
      from_as_object.iata if from_as_object.respond_to? :iata
    end

    def check_date
      errors.add :date, 'Первый вылет слишком рано' if date_as_date.present? && !TimeChecker.ok_to_show(date_as_date + 1.day)
    end

    def as_json(args = nil)
      args ||= {}
      args[:methods] = (args[:methods].to_a + [:to_as_object, :from_as_object]).uniq
      super(args)
    end

    def location_from_string name
      record = Completer.record_from_string(name) rescue nil
      if record
        if record.code && (['country', 'city', 'airport'].include? record.type)
          record.original_object
        elsif record.type == 'region'
          Region.first(:conditions => ['name_ru = ? OR name_en = ?', record.name, record.name])
        end
      end
    end

    def from_country_or_region?
      [Country, Region].include? from_as_object.class
    end

    def search_around_from
      from_as_object.class == City && from_as_object.search_around
    end

    def search_around_to
      to_as_object.class == City && to_as_object.search_around
    end

    def to_country_or_region?
      [Country, Region].include? to_as_object.class
    end

    def multicity?
      from_country_or_region? || to_country_or_region?
    end

    def date_as_date
      begin
        @date_as_date ||= Date.strptime(date, '%d%m%y')
      rescue
        nil
      end
    end

    def to_as_object
      @to_as_object ||= location_from_string(to)
    end

    def from_as_object
      @from_as_object ||= location_from_string(from)
    end

    def to_iata
      to_as_object_iata
    end

    def from_iata
      from_as_object_iata
    end

    def nearby_cities
      [from_as_object, to_as_object].map do |location|
        if location.class == City
          location.nearby_cities
        elsif location.class == Airport
          location.city.nearby_cities
        else
          []
        end
      end
    end
  end

  # FIXME обходит необходимость использовать segments_attributes в жаваскрипте
  # но нет уверенности, что не создаю каких-то дополнительных проблем
  def segments=(attrs)
    self.segments_attributes = attrs
  end

  def date1
    segments.first.date
  end

  def date2
    segments[1].date if segments[1]
  end

  def dates
    [date1, date2] if date2
    [date1]
  end

  def save_to_cache
    self.query_key ||= ShortUrl.random_hash
    save
  end

  class << self
    def load_from_cache(query_key)
      pricer_form = PricerForm.where(:query_key => query_key).last
      if pricer_form
        pricer_form.inc(:use_count, 1)
      end
      pricer_form
    end
    alias :[] load_from_cache
  end

  def as_json(args)
    args ||= {}
    args[:methods] = (args[:methods].to_a + [:people_count, :complex_to_parse_results, :segments, :rt]).uniq
    super(args)
  end

  def rt
    (segments.length == 2) && (segments[0].to_as_object == segments[1].from_as_object) && (segments[1].to_as_object == segments[0].from_as_object)
  end

  # для рассчета тарифов
  # младенцы с местом считаются детьми
  # FIXME переименовать во что-то типа tariff_count
  def real_people_count
    {
      :adults => adults,
      :children => children + ((adults < infants) ? (infants - adults) : 0 ),
      :infants => (adults >= infants) ? infants : adults
    }
  end

  # понадобится мест в самолете
  def seat_total
    real_people_count.values_at(:adults, :children).sum
  end

  def people_count
    {:adults => adults || 1, :children => children || 0, :infants => infants || 0}
  end

  def people_total
    [adults, children, infants].compact.sum
  end

  def cabin_list
    case cabin
    when 'C'
      return ['C', 'F']
    when nil
      return []
    else
      return [cabin]
    end
  end

  def people_count= count
    self.adults, self.children, self.infants = count[:adults] || 1, count[:children] || 0, count[:infants] || 0
  end

  # в этом порядке!
  before_validation :parse_complex_to
  before_validation :fix_segments

  # заполняет невведенные from во втором и далее сегментах
  def fix_segments
    segments.each_cons(2) do |a, b|
      if b.from.empty?
        b.from = a.to
      end
    end
  end

  def parse_complex_to
    self.complex_to ||= segments[0].to.gsub(',', ' ')
    res = {}
    str = self.complex_to.mb_chars
    not_finished = true
    while !str.blank? && not_finished
      day = 0
      month_record = nil
      word_part = ''
      not_finished = false
      if m = str.match(/(\S+)\s+(\d)+\s*$/)
        word_part = m[0].mb_chars
        month_record = Completer.record_from_string(m[1].mb_chars, ['date'])
        day = m[2].to_i
      elsif m = str.match(/(\d+)\s+(\S+)\s*$/)
        word_part = m[0].mb_chars
        month_record = Completer.record_from_string(m[2].mb_chars, ['date'])
        day = m[1].to_i
      end

      if month_record && (day > 0) && (month_record.hidden_info.class == Fixnum)
        res[:dates] =[{
            :value => date_from_month_and_day(month_record.hidden_info, day),
            :str => word_part.to_s,
            :start => str.length - word_part.length,
            :end => str.length-1}
          ]
        str = str[0...(str.length - word_part.length)]
        not_finished = true
      end

      for word_beginning_pattern in [ /\S+\s+\S+\s+\S+\s*$/, /\S+\s+\S+\s*$/, /\S+\s*$/ ]
        if (m = str.match(word_beginning_pattern)) && !not_finished
          word_part = m[0].mb_chars

          if r = Completer.record_from_string(word_part, ['date', 'airport', 'city', 'country', 'people'])
            if r && r.type == 'date' && r.hidden_info.class == String
              res[:dates] = [{
                  :value => r.hidden_info,
                  :str => word_part.to_s,
                  :start => str.length - word_part.length,
                  :end => str.length-1}
                ]
              str = str[0...(str.length - word_part.length)]
              not_finished = true
            elsif r && (['airport', 'city', 'country', 'region'].include? r.type)
              segments[0].to = r.name rescue nil
              res[:to] = {
                :value => r.name,
                :str => word_part.to_s,
                :start => str.length - word_part.length,
                :end => str.length-1
              }
              str = str[0...(str.length - word_part.length)]
              not_finished = true
            elsif r && r.type == 'people'
              res[:people_count] = {
                :value => r.hidden_info,
                :str => word_part.to_s,
                :start => str.length - word_part.length,
                :end => str.length-1
              }
              str = str[0...(str.length - word_part.length)]
              not_finished = true
            end
          end
        end
      end
    end
    @complex_to_parse_results = res
  end

  def date_from_month_and_day(month, day)
    self.segments[0].date = (Date.today > Date.new(Date.today.year, month, day)) ?
      Date.new(Date.today.year+1, month, day).strftime('%d%m%y') :
      Date.new(Date.today.year, month, day).strftime('%d%m%y')
  end

  def to_key
    []
  end

  def complex_route?
    segments.length > 1 && !rt
  end

  def details
    return {} unless valid?
    result = {}
    
    human_parts = []
    person_parts = []
    if adults > 1
      person_parts << ['вдвоем', 'втроем', 'вчетвером', 'впятером', 'вшестером', 'всемером', 'ввосьмером'][adults-2]
    end
    if children > 0
      person_parts << ['с&nbsp;ребенком', 'с&nbsp;двумя детьми', 'с&nbsp;тремя детьми', 'с&nbsp;четырьмя детьми', 'с&nbsp;пятью детьми', 'с&nbsp;шестью детьми', 'с&nbsp;семью детьми'][children-1]
    end
    person_parts << 'и' if infants > 0 && children > 0
    if infants > 0
      person_parts << ['с&nbsp;младенцем', 'с&nbsp;двумя младенцами', 'с&nbsp;тремя младенцами', 'с&nbsp;четырьмя младенцами', 'с&nbsp;пятью младенцами', 'с&nbsp;шестью младенцами', '7 младенцев'][infants-1]
    end
    unless person_parts.empty?
      human_parts << person_parts.join(' ')
    end

    case cabin
    when 'C'
      human_parts << 'бизнес-классом'
    when 'F'
      human_parts << 'первым классом'
    end

    result[:options] = {
      :adults => adults,
      :children => children,
      :infants => infants,
      :total => adults + children + infants,
      :cabin => cabin,
      :human => human_parts.join(', ')
    }

    result[:segments] = segments.map{|segment|
      dpt = segment.from_as_object
      arv = segment.to_as_object 
      {
        :title => "#{ dpt.case_from } #{ arv.case_to }",
        :arvto => "#{ arv.case_to }",
        :date => segment.date,
        :dpt => {:name => dpt.name},
        :arv => {:name => arv.name},
      }
    }
    result[:segments][1][:rt] = true if rt

    result
  end
  
  def human_short
    if rt
      "#{segments[0].from_as_object.name} &harr; #{segments[0].to_as_object.name}, #{short_date(segments[0].date)} — #{short_date(segments[1].date)}"
    else
      parts = []
      segments.each do |segment|
        parts << "#{segment.from_as_object.name} &rarr; #{segment.to_as_object.name} #{short_date(segment.date)}"
      end      
      parts.join(', ')
    end  
  end  
  
  def map_segments
    result = segments.map{|s|
      { 
        :dpt => map_point(s.from_as_object),
        :arv => map_point(s.to_as_object)
      }
    }
    if result.length == 1
      dpt = segments.first.from_as_object
      arv = segments.first.to_as_object
      if dpt && arv
        dpt_alpha2 = dpt.class == Country ? dpt.alpha2 : dpt.country.alpha2
        arv_alpha2 = arv.class == Country ? arv.alpha2 : arv.country.alpha2
        if dpt_alpha2 == 'RU' && (arv_alpha2 == 'US' || arv_alpha2 == 'IL' || arv_alpha2 == 'GB')
          result.first[:leave] = true
        end
      end
    end
    result
  end
  
  def map_point obj
    obj && {
      :name => obj.name,
      :lat => obj.lat,
      :lng => obj.lng
    }
  end      

  def human_lite
    segments[0].from_as_object.name + (rt ? ' ⇄ ' : ' → ') + segments[0].to_as_object.name
  end

  def nearby_cities
    #FIXME
    segments[0].nearby_cities
  end

  def human_locations
    result = {}
    segments.each_with_index do |fs, i|
      if fs.from_as_object && fs.to_as_object
        result['dpt_' + i.to_s] = fs.from_as_object.case_from
        result['arv_' + i.to_s] = fs.to_as_object.case_to
      end
    end
    result
  end

  def human_date(ds)
    d = Date.strptime(ds, '%d%m%y')
    if d.year == Date.today.year
      return I18n.l(d, :format => '%e&nbsp;%B')
    else
      return I18n.l(d, :format => '%e&nbsp;%B %Y')
    end
  end
  
  def short_date(ds)
    ds[0,2] + '.' + ds[2,2]
  end  
  
end

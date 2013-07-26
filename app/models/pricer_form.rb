# encoding: utf-8

class PricerForm
  include Virtus

  attribute :errors, Array, :default => []
  attribute :adults, Integer, :default => 1
  attribute :children, Integer, :default => 0
  attribute :infants, Integer, :default => 0
  attribute :cabin
  attribute :query_key
  attribute :partner
  attribute :use_count, Integer, :default => 1
  attribute :segments, Array[SearchSegment]
  delegate :to, :from, :from_iata, :to_iata, :to => 'segments.first'

  # валидация
  def valid?
    fix_segments!
    check_segments
    # валидируем сегменты
    errors.concat(segments.flat_map { |s| s.valid?; s.errors } )
    errors.blank?
  end

  def check_segments
    # может случаться во время проверки PricerController#validate
    errors << 'Не содержит сегментов' unless segments.present?
    errors << 'В сегменте не может отсутствовать место прибытия' unless segments.all? { |s| s.to }
    errors << 'В сегменте не может отсутствовать дата вылета' unless segments.all? { |s| s.date }
  end

  def check_people_total
    errors << 'Количество пассажиров не должно быть больше восьми' if people_total > 8
  end

  # заполняет невведенные from во втором и далее сегментах
  def fix_segments!
    if @segments
      @segments.each_cons(2) do |a, b|
        if b.from.empty?
          b.from = a.to
        end
      end
    end
  end
  #/валидация

  def segments=(segments)
    if segments.is_a?(Hash)
      # для PricerController#validate
      # TODO: убрать
      segments = segments.map do |k, v|
        # FIXME: переписать как-нибудь нормально
        next unless v[:date] || v[:to]
        SearchSegment.new(v)
      end
      segments.compact!
    end
    @segments = segments
    fix_segments!
  end

  # урлы
  def self.from_code(code)
    # затычка для старых урлов
    return load_from_cache(code) if code.size == 6
    Urls::Search::Decoder.new(code).decoded
  end

  def encode_url
    encoder = Urls::Search::Encoder.new(self)
    encoder.url
  end
  # /урлы

  # перенести в хелпер
  def self.convert_api_date(date_str)
    if date_str =~ /^20(\d\d)-(\d\d?)-(\d\d?)$/
      "%02d%02d%02d" % [$3, $2, $1].map(&:to_i)
    else
      date_str
    end
  end

  def hash_for_rambler
    return if complex_route?
    res = {
      :src => from_iata,
      :dst => to_iata,
      :dir => segments[0].date_as_date.strftime('%Y-%m-%d'),
      :cls => RamblerCache::CABINS_MAPPING[cabin] || 'E',
      :adt => adults,
      :cnn => children,
      :inf => infants,
      :wtf => 0
    }
    res.merge!({:ret => segments[1].date_as_date.strftime('%Y-%m-%d')}) if segments[1]
    res
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

    segments = [SearchSegment.new(from: args[:from], to: args[:to], date: convert_api_date(args[:date1]))]
    if args[:date2].present?
      segments << SearchSegment.new(from: args[:to], to: args[:from], date: convert_api_date(args[:date2]))
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
        :short => "#{ dpt.iata } &rarr; #{ arv.iata }",
        :arvto => "#{ arv.case_to }",
        :arvto_short => "в #{ arv.iata }",
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
      complex = segments.length > 1
      segments.each do |segment|
        if complex
          parts << "#{segment.from_as_object.iata} &rarr; #{segment.to_as_object.iata} #{short_date(segment.date)}"
        else
          parts << "#{segment.from_as_object.name} &rarr; #{segment.to_as_object.name} #{short_date(segment.date)}"
        end
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
      :from => obj.case_from,
      :iata => obj.iata,
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


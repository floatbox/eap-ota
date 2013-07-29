# encoding: utf-8

class PricerForm
  include Virtus
  include Search::Humanize::Presenter

  attribute :errors, Array, :default => []
  attribute :adults, Integer, :default => 1
  attribute :children, Integer, :default => 0
  attribute :infants, Integer, :default => 0
  attribute :cabin, String
  attribute :query_key, String
  attribute :partner, String
  attribute :use_count, Integer, :default => 1
  attribute :segments, Array[SearchSegment]
  delegate :to, :from, :from_iata, :to_iata, :date, :to => 'segments.first'

  # валидация
  def valid?
    #fix_segments!
    check_segments
    errors.blank?
  end

  def check_segments
    # может случаться во время проверки PricerController#validate
    errors << 'Не содержит сегментов' unless segments?
    errors.concat(segments.flat_map { |s| s.valid?; s.errors } )
  end

  def segments?
    segments.present?
  end

  def check_people_total
    errors << 'Количество пассажиров не должно быть больше восьми' if people_total > 8
  end

  # заполняет невведенные from во втором и далее сегментах
  #def fix_segments!
    #if @segments
      #@segments.each_cons(2) do |a, b|
        #if b.from.empty?
          #b.from = a.to
        #end
      #end
    #end
  #end
  #/валидация

  # конструкторы
  def self.from_code(code)
    # затычка для старых урлов
    return load_from_cache(code) if code.size == 6
    Search::Urls::Decoder.new(code).decoded
  end

  def self.from_js(params_raw)
    params_raw = HashWithIndifferentAccess.new(params_raw)
    people_count = params_raw[:people_count]
    params = params_raw.merge(people_count) if people_count
    params.except!(:people_count)
    params[:segments] = params[:segments].values

    new(params)
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
  # /конструкторы

  def encode_url
    encoder = Search::Urls::Encoder.new(self)
    encoder.url
  end

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

  def rt
    (segments.length == 2) && (segments[0].to == segments[1].from) && (segments[1].to == segments[0].from)
  end

  # для рассчета тарифов
  # младенцы с местом считаются детьми
  def tariffied
    {
      :adults => adults,
      :children => children + ((adults < infants) ? (infants - adults) : 0 ),
      :infants => (adults >= infants) ? infants : adults
    }
  end

  # понадобится мест в самолете
  def seat_total
    tariffied.values_at(:adults, :children).sum
  end

  def people_count
    {:adults => adults || 1, :children => children || 0, :infants => infants || 0}
  end

  def people_total
    [adults, children, infants].compact.sum
  end

  def people_count= count
    self.adults, self.children, self.infants = count[:adults] || 1, count[:children] || 0, count[:infants] || 0
  end

  def complex_route?
    segments.length > 1 && !rt
  end

  def map_segments
    result = segments.map{|s|
      { 
        :dpt => map_point(s.from),
        :arv => map_point(s.to)
      }
    }
    if result.length == 1
      dpt = from
      arv = to
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

  def nearby_cities
    #FIXME
    segments[0].nearby_cities
  end

end


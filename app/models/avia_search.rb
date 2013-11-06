# encoding: utf-8

class AviaSearch
  include Virtus
  include Search::Defaults
  include Search::Humanize::Presenter
  include ActiveModel::Validations

  attribute :adults, Integer, :default => ADULTS
  attribute :children, Integer, :default => CHILDREN
  attribute :infants, Integer, :default => INFANTS
  attribute :cabin, String, :default => CABIN
  attribute :partner, String
  attribute :segments, Array[AviaSearchSegment]
  delegate :to, :from, :from_iata, :to_iata, :date, :to => 'segments.first'

  validates_presence_of :segments
  validates_numericality_of :adults, :children, in: 1..6
  validates_numericality_of :infants, in: 1..4
  validates_numericality_of :people_total, less_than_or_equal_to: 8
  validate :segments_validity

  def segments_validity
    segments_errors = segments.flat_map { |s| s.valid?; s.errors.full_messages }
    errors.add(:segments, segments_errors.join('; ')) if segments_errors.present?
  end

  # конструкторы
  def self.from_code(code)
    Search::Urls::Decoder.new(code).decoded
  end

  # нужен для PricerController#validate
  # если от него избавимся - можно удалять
  def self.from_js(params_raw)
    params_raw = HashWithIndifferentAccess.new(params_raw)
    people_count = params_raw[:people_count]
    params = params_raw.merge(people_count) if people_count
    params.except!(:people_count)
    segments = params[:segments] ? params[:segments].values : []
    params[:segments] = segments.map do |segment|
      segment[:from] = Completer.object_from_string(segment[:from])
      segment[:to] = Completer.object_from_string(segment[:to])
      segment
    end

    new(params)
  end

  # FIXME переделать в builder тоже? с отдельной валидацией, мейби.
  SIMPLE_PARAMS = %W[
    from to
    from1 from2 from3 from4 from5 from6
    to1 to2 to3 to4 to5 to6
    date1 date2 date3 date4 date5 date6
    adults children infants cabin partner
  ]

  def self.simple(args)
    args = args.dup.stringify_keys!

    args["from1"] ||= args["from"]
    args["to1"] ||= args["to"]
    # можно не указывать обе точки второго сегмента для туда-обратно
    args["from2"] ||= args["to1"]
    args["to2"] ||= args["from1"]
    # можно не указывать fromN для неразрывных маршрутов
    ("date2".."date6").zip("from2".."from6", "to1".."to5").each do |date, from, to|
      args[from] ||= args[to] if args[date]
    end
    args.delete_if {|k, v| v.blank? }

    wrong_parameters = args.keys - SIMPLE_PARAMS
    unless wrong_parameters.empty?
      raise ArgumentError, "Unknown parameter(s) - \"#{wrong_parameters.join(', ')}\""
    end
    lack_of_parameters = %W[from1 to1 date1] - args.keys
    unless lack_of_parameters.empty?
      raise ArgumentError, "Lack of required parameter(s)  - \"#{lack_of_parameters.join(', ')}\""
    end

    segments = []
    (1..6).each do |i|
      # map и break не дружат
      break unless args["date#{i}"]
      segments << AviaSearchSegment.new(
        from: args["from#{i}"], to: args["to#{i}"], date: convert_api_date(args["date#{i}"])
      )
    end

    adults = (args["adults"] || 1).to_i
    children = args["children"].to_i
    infants = args["infants"].to_i
    cabin = args["cabin"]
    partner = args["partner"]

    new :segments => segments,
      :adults => adults, :children => children, :infants => infants, :cabin => cabin,
      :partner => partner
  end
  # /конструкторы

  def encode_url
    encoder = Search::Urls::Encoder.new(self)
    encoder.url
  end
  alias_method :query_key, :encode_url

  # перенести в хелпер
  def self.convert_api_date(date_str)
    if date_str =~ /^20(\d\d)-(\d\d?)-(\d\d?)$/
      "%02d%02d%02d" % [$3, $2, $1].map(&:to_i)
    else
      date_str
    end
  end

  def date1
    segments.first.date
  end

  def date2
    segments[1].date if segments[1]
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
    { :adults => adults, :children => children, :infants => infants }
  end

  def people_count= count
    self.adults, self.children, self.infants = count[:adults] || 1, count[:children] || 0, count[:infants] || 0
  end


  def people_total
    [adults, children, infants].compact.sum
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


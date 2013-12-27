# encoding: utf-8

class AviaSearch
  include Virtus.model
  include ActiveModel::Validations

  attribute :adults, Integer, default: 1
  attribute :children, Integer, default: 0
  attribute :infants, Integer, default: 0
  attribute :cabin, String, default: 'Y'
  attribute :segments, Array[AviaSearchSegment]
  delegate :to, :from, :from_iata, :to_iata, :date, :to => 'segments.first'

  validates_presence_of :segments
  validates_numericality_of :adults,   only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 6
  validates_numericality_of :children, only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 6
  validates_numericality_of :infants,  only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 4
  validates_numericality_of :people_total, less_than_or_equal_to: 8
  validate :segments_validity

  def segments_validity
    segments_errors = segments.flat_map { |s| s.valid?; s.errors.full_messages }
    errors.add(:segments, segments_errors.join('; ')) if segments_errors.present?
  end

  # конструкторы
  # TODO from_param? from_string?
  def self.from_code(code)
    AviaSearch::StringDecoder.new.decode(code)
  end

  # нужен для PricerController#validate
  # если от него избавимся - можно удалять
  def self.from_js(params_raw)
    AviaSearch::JsDecoder.new.decode(params_raw)
  end

  # в API
  def self.simple(args)
    AviaSearch::SimpleDecoder.new.decode(args)
  end

  def self.from_recommendation(rec, attrs={})
    segments = rec.segments.map do |s|
      {
        from: s.departure.city.iata,
        to: s.arrival.city.iata,
        date: s.departure_date
      }
    end
    new(attrs.reject {|k, v| v.blank? }.merge(segments: segments))
  end
  # /конструкторы

  def to_s
    AviaSearch::StringEncoder.new.encode(self)
  end
  alias_method :to_param, :to_s
  alias_method :query_key, :to_s

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

  def nearby_cities
    #FIXME
    segments[0].nearby_cities
  end

end


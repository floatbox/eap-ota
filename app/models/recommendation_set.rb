# encoding: utf-8

class RecommendationSet

  def self.wrap(arg)
    return arg if arg.is_a? RecommendationSet
    RecommendationSet.new(arg)
  end

  def initialize(recs=[])
    recs.is_a? Array or
      raise TypeError, "cannot init #{recs.class} with RecommendationSet"
    @recs = recs
  end

  attr_accessor :recs
  alias recommendations recs
  alias to_a recs
  delegate :each, :size, :empty?, :present?, :to => :recs

  def + other
    RecommendationSet.new( @recs + RecommendationSet.wrap(other).recs )
  end

  def process!(opts = {})
    select_full_info!
    reject_ground!
    find_commission!
    select_sellable! unless opts[:admin_user]

    # сортируем если ищем для морды
    sort! unless opts[:lite]
    # Выключил, потому что сейчас всегда один поиск.
    # Поиски по нескольким офисам надо будет группировать другим способом.
    # group! unless opts[:lite]
    clear_variants!
  end

  def select_full_info!
    @recs.select! &:full_information?
    @recs.select! &:valid_interline?
    @recs.reject! &:ignored_carriers
  end

  def reject_ground!
    @recs.reject! &:ground?
  end

  def select_sellable!
    @recs.select! &:sellable?
  end

  def clear_variants!
    @recs.each &:clear_variants
    @recs.select! &:variants?
  end

  def sort!
    @recs.sort_by! &:price_total
  end

  def find_commission!
    @recs.each &:find_commission!
  end

  # объединяем эквивалентные варианты
  def group!
    result = []
    @recs.each do |r|
      #некрасиво, но просто и работает
      # FIXME очень некрасиво! хорошо что скоро убьем.
      if groupable? r, result[-1]
        result[-1].variants += r.variants
      elsif groupable? r, result[-2]
        result[-2].variants += r.variants
      elsif groupable? r, result[-3]
        result[-3].variants += r.variants
      else
        result << r
      end
    end
    @recs = result
  end

  def groupable? rec1, rec2
    rec2 or return
    %W[
      price_fare
      price_tax
      validating_carrier_iata
      booking_classes
      marketing_carrier_iatas
    ].all? do |attr|
      rec1.send(attr) == rec2.send(attr)
    end
  end

  def filters_data
    Recommendation.filters_data @recs
  end

  # FIXME осторожно! опирается на факт предварительной сортировки!
  def cheapest
    recs.first
  end

end


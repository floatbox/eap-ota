# encoding: utf-8

class RecommendationSet

  include ActiveSupport::Benchmarkable
  cattr_accessor :logger do
    ForwardLogging.new(Rails.logger, Logger::DEBUG)
  end

  def self.wrap(arg)
    return arg if arg.is_a? RecommendationSet
    RecommendationSet.new(arg)
  end

  def initialize(recs=[])
    recs.is_a? Array or
      raise TypeError, "cannot init #{recs.class} with RecommendationSet"
    @recs = recs
  end

  attr_accessor :context
  attr_accessor :recs
  alias recommendations recs
  alias to_a recs
  delegate :each, :size, :empty?, :present?, :to => :recs

  def + other
    RecommendationSet.new( @recs + RecommendationSet.wrap(other).recs )
  end

  def process!(opts = {})
    self.context = opts[:context] or raise ArgumentError, "needs context"
    benchmark 'RecommendationSet: process!, total', level: :info do
      run :select_full_information!
      run :select_valid_interline!
      run :reject_ignored_carriers! if context.pricer_filter?
      run :reject_ignored_flights! if context.pricer_filter?
      run :reject_ground! if context.pricer_filter?
      run :find_commission!
      run :select_sellable! if context.pricer_filter?

      # сортируем если ищем для морды
      run :sort! if context.pricer_sort?
      # Выключил, потому что сейчас всегда один поиск.
      # Поиски по нескольким офисам надо будет группировать другим способом.
      # run :group! if context.pricer_sort?
      run :clear_variants!
    end
  end

  # запускает подпроцесс и репортит его время и еще что-нибудь.
  def run stage
    benchmark "RecommendationSet: #{stage}", level: :debug do
      send stage
    end
  end

  def select_full_information!
    @recs.select! &:full_information?
  end

  def select_valid_interline!
    @recs.select! &:valid_interline?
  end

  def reject_ignored_carriers!
    @recs.reject! &:ignored_carriers?
  end

  def reject_ignored_flights!
    @recs.reject! &:ignored_flights?
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
    @recs.each {|rec| rec.find_commission! context: context}
  end

  # сейчас вызывается дополнительным проходом, вне mux
  def remove_unprofitable!(income_at_least)
    @recs.reject! {|r| r.income < income_at_least} if income_at_least
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


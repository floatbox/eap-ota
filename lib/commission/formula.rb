# encoding: utf-8
#
# формула для рассчетов комиссий и сборов.
# понимает проценты, абсолютные значения, и даже другие валюты (иногда)
class Commission::Formula

  extend SimpleFlyweight

  attr_accessor :formula, :compiled

  def initialize formula
    @formula = formula.to_s.strip
    compile!
  end

  def complex?
    !!formula['+']
  end

  def percentage?
    raise ArgumentError, "#{formula} contains several parts" if complex?
    !!formula['%']
  end

  def zero?
    rate.zero?
  end

  delegate :blank?, :to => :formula

  def euro?
    raise ArgumentError, "#{formula} contains several parts" if complex?
    !!formula['eur']
  end

  def rate
    raise ArgumentError, "#{formula} contains several parts" if complex?
    formula.to_f
  end

  def to_s
    formula
  end

  def inspect
    "#<Fx #{formula} >"
  end

  def compile!
    return unless valid?
    cached_rate = rate unless complex?

    @compiled =
      case

      when complex?

        formulas = formula.split('+').map do |f|
          Commission::Formula.new(f)
        end

        lambda do |base, multiplier, params|
          formulas.map { |f| f.call(base, params) }.inject(:+)
        end

      when percentage?

        lambda do |base, multiplier, params|
          cached_rate * base / 100
        end

      when euro?

        lambda do |base, multiplier, params|
          cached_rate * params[:eur].to_f * multiplier
        end

      else
        lambda do |base, multiplier, params|
          cached_rate * multiplier
        end

      end
  end

  def call(base=nil, params={:eur => Conf.amadeus.euro_rate})
    raise ArgumentError, "formula '#{@formula}' is not valid" unless compiled
    multiplier = (params[:multiplier] || 1).to_i
    compiled.call(base, multiplier, params).round(2)
  end

  alias [] call

  # fx#reverse_call считает надбавку к числу, такую, что
  # fx#call на сумму числа и надбавки вернет как раз эту надбавку.
  # сейчас служит для рассчета компенсации за эквайринг
  #
  # TODO euro? usd? multiplier? complex?
  def reverse_call(base=nil)
    raise ArgumentError, "formula '#{@formula}' is not valid" unless valid?
    if complex?
      # TODO write something? for cases like "2.34% + 0.1usd". it should be possible
      raise TypeError, "complex formulas aren't reversible for now"
    elsif euro?
      raise TypeError, "euro formulas aren't reversible for now"
    elsif percentage?
      rate * base / (100 - rate)
    else
      rate
    end.round(2)
  end

  def valid?
    formula.blank? ||
    !!( formula.strip =~ /^ \d+ (?: \.\d+ )? (?: % | eur )?
              ( \s* \+ \s*  \d+ (?: \.\d+ )? (?: % | eur )? )*  $/x )
  end

  def == other_formula
    return true if zero? && other_formula.zero?
    formula == other_formula.formula
  end

  # Сериализация

  # для YAML/Psych

  # FIXME надо как-то быть уверенными что этот когд исполняется
  # всегда, до любой десериализации.
  YAML.add_domain_type 'eviterra.com,2011', 'fx' do |type, val|
    Commission::Formula.new(val)
  end

  def encode_with(coder)
    coder.represent_scalar '!fx', @formula
  end

  # для обратной совместимости со старой сериализацией.
  # (ruby/object:Commission::Formula...)
  def init_with(coder)
    @formula = coder["formula"]
    compile!
  end

end

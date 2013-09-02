# encoding: utf-8
#
# формула для рассчетов комиссий и сборов.
# понимает проценты, абсолютные значения, и даже другие валюты (иногда)
class Commission::Formula

  include Comparable
  extend SimpleFlyweight

  KEYS = %w{% eur usd rub}
  KEY_REGEXP = /(#{ Regexp.union(KEYS) })/

  delegate :[], to: :parts

  attr_accessor :formula, :compiled, :parts

  def initialize data
    case data
    when Hash, Array
      compose! data
    else
      parse! data
    end
  end

  def complex?
    @parts.keys.size > 1
  end

  def zero?
    !@parts.values.any?(&:nonzero?)
  end

  delegate :blank?, :to => :formula

  def percentage?
    raise ArgumentError, "#{formula} contains several parts" if complex?
    !!@parts['%']
  end

  def euro?
    raise ArgumentError, "#{formula} contains several parts" if complex?
    !!@parts['eur']
  end

  # FIXME проверить где используется, можно ли туда возвращать FixNum?
  def rate
    raise ArgumentError, "#{formula} contains several parts" if complex?
    @parts.values.first.to_f
  end

  def to_s
    formula
  end

  def inspect
    "#<Fx #{formula} >"
  end

  def valid?
    !@invalid
  end

  def call(base=nil, params={:eur => Amadeus::Rate.euro_rate})
    raise ArgumentError, "formula '#{@formula}' is not valid" unless valid?
    multiplier = (params[:multiplier] || 1).to_i
    @parts.map do |part, rate|
      case part
      when '%'
        rate * base / 100
      when 'eur'
        rate * params[:eur].to_f * multiplier
      when 'rub'
        rate * multiplier
      else
        raise ArgumentError, "unknown part: #{part} in formula #{@formula}"
      end
    end.sum(0).round(2)
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

  def == other_formula
    @parts == other_formula.parts
  end

  # работает по таким законам:
  # если указана процентная ставка - всегда больше, чем без неё
  # иначе они просто сравниваются
  # то же касается и валюты
  # приоритеты:
  # % > eur > usd > rub
  # никаких конверсий для валют не выполняется
  def <=> other_formula
    # для нулевых формул
    return 0 if self == other_formula

    itself, other = @parts, other_formula.parts

    KEYS.each do |currency|
      ours = itself[currency]
      another = other[currency]
      return 1 if ( ours && !another )
      return -1 if ( another && !ours )
      cmp = ours <=> another if ( ours && another )
      return cmp if cmp && cmp.nonzero?
    end

    0
  end

  # Вычитание формулы с формулой, почленно.
  def + other_formula
    itself, other = @parts, other_formula.parts

    result = itself.merge(other)

    same_keys = itself.keys & other.keys
    same_keys.each { |key| result[key] = itself[key] + other[key] }

    Commission::Formula.new(result)
  end

  # Вычитание формулы из формулы, почленно.
  def - other_formula
    self + -other_formula
  end

  # Унарный минус. Разворачивает все ставки.
  def -@
    Commission::Formula.new(
      @parts.map {|k, v| [k, -v]}
    )
  end

  # Умножает все ставки в формуле на коэффициент.
  def * (value)
    Commission::Formula.new(
      @parts.map {|k, v|  [k, v*value] }
    )
  end

  # Делит все ставки в формуле на коэффициент.
  def / (value)
    Commission::Formula.new(
      @parts.map {|k, v|  [k, v/value] }
    )
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
    formula = coder["formula"]
    parse! formula
  end

  # строка => хеш, нужно для арифметических операций на формулах
  def parse! formula
    @formula = formula.to_s
    pairs = @formula.split(/(?=[+-])/).map do |part|
      part.tr! ' ', ''
      value, currency = part.split(KEY_REGEXP)
      currency ||= 'rub'
      value = Float(value)
      next if value.zero?
      [currency, value]
    end.compact
    @parts = Hash[pairs]
  rescue TypeError, ArgumentError
    @invalid = true
  end

  def compose! parts
    @parts = Hash[parts]
    @parts.assert_valid_keys(KEYS)
    @parts.reject! {|k, v| v.nil? || v.zero?}
    string = KEYS.map { |part|
      rate = @parts[part]
      next unless rate
      part = '' if part == 'rub'
      # делаем числа без вещественной части интами
      rate = rate.to_i if rate == rate.to_i
      sign = (rate < 0) ? '-' : '+'
      "#{sign} #{rate.abs}#{part}"
    }.compact.join(' ').sub(/^\+ /,'').sub(/^- /,'-')
    @formula = string.presence || '0'
  rescue ArgumentError
    @formula = parts.to_s
    @invalid = true
  end

end


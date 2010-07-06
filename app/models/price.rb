class Price
  def initialize(value)
    @value = value
  end

  def as_json options={}
    {
      :value => value,
      :currency => currency,
      :mode => mode,
      :hint => hint
    }
  end

  def value
    @value.to_i
  end

  alias :to_i :value

  def currency
    "RUB"
  end

  def hint
    "#{value} #{Russian.p(value, 'рубль', 'рубля', 'рублей')}"
  end

  attr_accessor :mode

  # сделать коэрцию?
  def + other
    if Price === other
      Price.new( value + other.value )
    else
      Price.new( value + other )
    end
  end

  def * multiplier
    Price.new( value * multiplier )
  end

  def <=> other
    value <=> other.value
  end
end

class BaggageLimit
  include KeyValueInit
  attr_writer :baggage_weight, :baggage_type, :baggage_quantity, :measure_unit

  def unknown?
    !@baggage_quantity && !@baggage_weight
  end

  def no_baggage?
    @baggage_quantity == 0 || @baggage_weight == 0
  end

  def units?
    @baggage_type == 'N'
  end

  def weight?
    @baggage_type == 'W'
  end

  def units
    units? && @baggage_quantity
  end

  def kilos
    weight? && @measure_unit == 'K' && @baggage_weight
  end

  def pounds
    weight? && @measure_unit == 'L' && @baggage_weight
  end

  def signature
    [units, kilos, pounds]
  end

  def ==(other)
    signature == other.signature
  end

  def hash
    signature.hash
  end
end

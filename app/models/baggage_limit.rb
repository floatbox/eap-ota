# encoding: utf-8
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

  def serialize
    if units?
      "#{units}N"
    elsif kilos
      "#{kilos}K"
    elsif pounds
      "#{pounds}L"
    else
      "?"
    end
  end

  def self.deserialize(code)
    if code == '?'
      self.new
    elsif code[-1] == 'N'
      self.new(:baggage_quantity => code[0].to_i, :baggage_type => 'N')
    elsif code[-1].in? ['L', 'K']
      self.new(:baggage_weight => code[0].to_i, :baggage_type => 'W', :measure_unit => code[1])
    else
      raise ArgumentError, 'Некорректный код багажа'
    end
  end

end

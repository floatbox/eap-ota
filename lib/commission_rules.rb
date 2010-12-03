module CommissionRules

  def self.included base
    base.send :extend, ClassMethods
  end

  include KeyValueInit

  attr_accessor :carrier, :agent, :subagent, :disabled, :interline,
    :domestic, :international, :klass, :departure, :departure_country,
    :check, :examples

  KLASSES = {
    :first => %W(P F A),
    :business => %W(D I Z J C),
    :economy => %W(B H K L M N Q T V X W S Y)
  }

  def applicable? recommendation
    #return unless carrier == recommendation.validating_carrier_iata
    return unless applicable_classes?(recommendation)
    return if disabled
    true
  end

  def applicable_classes?(recommendation)
    return true unless klass
    # symbol(s)?
    if Array(klass)[0].is_a? Symbol
      letters = Array(klass).map {|k| KLASSES[k]}.flatten
    else
      letters = klass.split('')
    end
    (recommendation.booking_classes - letters).blank?
  end

  def share(fare)
    # FIXME сделать поддержу EUR
    if subagent['%']
      fround(fare * subagent.to_f / 100)
    else
      fround(subagent.to_f)
    end
  end

  def agent_percentage?
    agent['%']
  end

  def agent_euro?
    agent['eur']
  end

  def agent_value
    val = agent.to_i
    val *= euro_rate if agent_euro?
    val
  end

  #FIXME нужно починить для работы с валютой
  def euro_rate
    43
  end

  private

  def fround x
    ('%.2f' % x.to_f).to_f
  end



  module ClassMethods

    mattr_accessor :commissions
    self.commissions = {}

    def carrier carrier
      if carrier =~ /\A..\Z/
        @carrier = carrier
      elsif carrier =~ /\(([A-Z0-9]{2})\)/
        @carrier = $1
      else
        raise ArgumentError, "strange carrier: #{carrier}"
      end
    end

    # один аргумент, разделенный пробелами или /; или два аргумента
    def commission *args, &block
      if args.size == 1
        if args == [0]
          vals = [0, 0]
        else
          vals = args[0].split(/[ \/]+/)
        end
      else
        vals = args
      end
      if vals.size != 2
        raise ArgumentError, "strange commission: #{args.join(' ')}"
      end

      commission = new(:carrier => @carrier, :agent => vals[0], :subagent => vals[1])

      # дополнительные параметры бронирования
      if block_given?
        Definition.new(commission).instance_eval(&block)
      end

      commissions[@carrier] ||= []
      commissions[@carrier] << commission
      commission
    end

    def disabled_commission *args, &block
      commission(*args, &block).disabled = true
    end

    def p
      p commissions
    end

    def find_for(recommendation)
      (commissions[recommendation.validating_carrier_iata] || []).find {|c| c.applicable?(recommendation) }
    end
  end

  # вспомогательный класс для украшения синтаксиса
  class Definition
    def initialize(commission)
      @commission = commission
    end

    def method_missing sym, *args, &block
      if block_given?
        @commission.send :"#{sym}=", block
      elsif args.empty?
        @commission.send :"#{sym}=", true
      elsif args.size > 1
        @commission.send :"#{sym}=", args
      else
        @commission.send :"#{sym}=", *args
      end
    end
  end
end

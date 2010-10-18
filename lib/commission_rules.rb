module CommissionRules

  def self.included base
    base.send :extend, ClassMethods
  end

  include KeyValueInit

  attr_accessor :carrier, :agent, :subagent, :disabled, :interline,
    :domestic, :international, :klass, :departure, :departure_country,
    :check

  def applicable? recommendation
    return unless carrier == recommendation.validating_carrier_iata
    true
  end

  def markup(tariff)
    if subagent['%']
      fround(tariff * subagent.to_f / 100)
    else
      fround(subagent.to_f)
    end
  end

  private

  def fround x
    ('%.2f' % x.to_f).to_f
  end



  module ClassMethods

    mattr_accessor :commissions
    self.commissions = []

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
        vals = args[0].split(/[ \/]+/)
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

      commissions << commission
      commission
    end

    def disabled_commission *args, &block
      commission(*args, &block).disabled = true
    end

    def p
      p commissions
    end

    def find_for(recommendation)
      commissions.find {|c| c.applicable?(recommendation) }
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
      else
        @commission.send :"#{sym}=", *args
      end
    end
  end
end

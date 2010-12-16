module CommissionRules

  def self.included base
    base.send :extend, ClassMethods
  end

  include KeyValueInit

  attr_accessor :carrier, :agent, :subagent, :disabled, :interline,
    :domestic, :international, :klass, :departure, :departure_country,
    :check, :examples, :agent_comments, :subagent_comments

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
    mattr_accessor :opts
    self.commissions = {}

    def carrier carrier, carrier_name=nil
      if carrier =~ /\A..\Z/
        @carrier = carrier
        @carrier_name = carrier_name
        self.opts={}
      else
        raise ArgumentError, "strange carrier: #{carrier}"
      end
    end

    # один аргумент, разделенный пробелами или /; или два аргумента
    def commission *args
      vals = args[0].split(/[ \/]+/)
      if vals.size != 2
        raise ArgumentError, "strange commission: #{args.join(' ')}"
      end

      commission = new({
        :carrier => @carrier,
        :agent => vals[0].to_s,
        :subagent => vals[1].to_s
      }.merge(opts))

      # дополнительные параметры бронирования

      commissions[@carrier] ||= []
      commissions[@carrier] << commission
      self.opts = {}
      commission
    end

    def disable
      opts[:disabled] = true
    end

    def interline value=:yes
      opts[:interline] = value
    end

    def agent line
      opts[:agent_comments] ||= ""
      opts[:agent_comments] += line + "\n"
    end

    def subagent line
      opts[:subagent_comments] ||= ""
      opts[:subagent_comments] += line + "\n"
    end

    def domestic
      opts[:domestic] = true
    end

    def international
      opts[:international] = true
    end

    def p
      p commissions
    end

    def find_for(recommendation)
      (commissions[recommendation.validating_carrier_iata] || []).find {|c| c.applicable?(recommendation) }
    end
  end

end

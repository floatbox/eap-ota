# encoding: utf-8
module CommissionRules

  def self.included base
    base.send :extend, ClassMethods
  end

  include KeyValueInit

  attr_accessor :carrier, :agent, :subagent, :disabled, :not_implemented, :no_commission, :interline,
    :domestic, :international, :klass, :departure, :departure_country,
    :check, :examples, :agent_comments, :subagent_comments, :source

  KLASSES = {
    :first => %W(P F A),
    :business => %W(D I Z J C),
    :economy => %W(B H K L M N Q T V X W S Y)
  }

  def disabled?
    disabled || not_implemented || no_commission
  end

  def applicable? recommendation
    not disabled? and
    # carrier == recommendation.validating_carrier_iata and
    applicable_interline?(recommendation) and
    applicable_classes?(recommendation)
  end

  def applicable_interline? recommendation
    case interline
    when :possible
      recommendation.validating_carrier_participates?
    when nil, :no
      not recommendation.interline?
    when :yes
      recommendation.interline? and # and recommendation.valid_interline?
        recommendation.validating_carrier_participates?
    # FIXME доделать:
    when :absent
      recommendation.interline? and
        not recommendation.validating_carrier_participates?
    when :first
      recommendation.interline? and
      recommendation.variants[0].flights.first.marketing_carrier_iata ==
        recommendation.validating_carrier_iata
    end
  end

  def applicable_classes? recommendation
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
    def commission arg
      vals = arg.split(/[ \/]+/)
      if vals.size != 2
        raise ArgumentError, "strange commission: #{args.join(' ')}"
      end

      commission = new({
        :carrier => @carrier,
        :agent => vals[0].to_s,
        :subagent => vals[1].to_s,
        :source => caller_address
      }.merge(opts))

      self.opts = {}
      register commission
    end

    # заглушка для example который _не должны_ найти комиссию
    def no_commission
      # opts здесь по идее содержит только examples
      commission = new({
        :carrier => @carrier,
        :source => caller_address,
        :no_commission => true
      }.merge(opts))

      self.opts = {}
      register commission
    end

    def register commission
      commissions[@carrier] ||= []
      commissions[@carrier] << commission
      commission
    end

    # параметры конкретных правил
    # задаются после carrier,
    # но перед commission/no_commission
    #############################

    # выключает правило
    def disabled reason=true
      opts[:disabled] = reason
    end
    alias_method :vague, :disabled

    def not_implemented
      opts[:not_implemented] = true
    end

    # правило интерлайна
    def interline value=:yes
      opts[:interline] = value
    end

    # строчки из агентского договора (FM, комиссии, указываемые в бронировании)
    def agent line
      opts[:agent_comments] ||= ""
      opts[:agent_comments] += line + "\n"
    end

    # строчки из субагентского договора (маржа, которую мы оставим себе от fare)
    def subagent line
      opts[:subagent_comments] ||= ""
      opts[:subagent_comments] += line + "\n"
    end

    # внутренние авиалинии
    def domestic
      opts[:domestic] = true
    end

    # внешние авиалинии
    def international
      opts[:international] = true
    end

    def klass klasses
      opts[:klass] = klasses
    end

    def example str
      opts[:examples] ||= []
      opts[:examples] << [str, caller_address]
    end

    # метод поиска рекомендации

    def find_for(recommendation)
      (commissions[recommendation.validating_carrier_iata] || return).find do |c|
        c.applicable?(recommendation)
      end
    end

    def exists_for?(recommendation)
      commissions[recommendation.validating_carrier_iata].blank?
    end

    # test methods
    def test
      commissions.values.flatten.each do |commission|
        (commission.examples || next).each do |code, source|
          rec = Recommendation.example(code, :carrier => commission.carrier)
          proposed = find_for(rec)
          if proposed == commission ||
             proposed.nil? && commission.disabled?
            ok "#{commission.carrier} (line #{source}): #{code} - OK"
          elsif proposed.nil?
            error "#{commission.carrier} (line #{source}): #{code} - no applicable commission!"
          else
            if commission.disabled?
              error "#{commission.carrier} (line #{source}): #{code} - commission non applicable, but got line #{proposed.source}:"
            else
              error "#{commission.carrier} (line #{source}): #{code} - wrong commission applied. Should be:"
              error "agent:    #{commission.agent_comments.chomp}"
              error "subagent: #{commission.subagent_comments.chomp}"
              error " got line #{proposed.source}:"
            end
            error "agent: #{proposed.agent_comments.chomp}"
            error "subagent: #{proposed.subagent_comments.chomp}"
          end
        end
      end

    end

    def stats
      puts "#{commissions.keys.size} carriers"
      puts "#{commissions.values.sum(&:size)} rules total"
      puts "#{commissions.values.every.select(&:disabled?).sum(&:size)} rules disabled"
      puts "#{commissions.values.every.select(&:not_implemented).sum(&:size)} of which not implemented"
      disabled, enabled = commissions.keys.partition {|iata| commissions[iata].all?(&:disabled?)}
      puts "enabled #{enabled.size}: #{enabled.sort.join(' ')}"
      puts "disabled #{disabled.size}: #{disabled.sort.join(' ')}"
    end

    private
    def error msg
      puts "\e[31m" + msg + "\e[0m"
    end

    def ok msg
      puts "\e[32m" + msg + "\e[0m"
    end

    def caller_address level=1
      caller[level] =~ /:(\d+)/
      $1 || 'unknown'
    end

  end

end

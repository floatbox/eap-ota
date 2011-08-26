# encoding: utf-8
module CommissionRules

  def self.included base
    base.send :extend, ClassMethods
  end

  include KeyValueInit

  attr_accessor :carrier, :agent, :subagent,
    :disabled, :not_implemented, :no_commission,
    :interline, :domestic, :international, :classes, :subclasses,
    :routes,
    :departure, :departure_country, :important,
    :check, :examples, :agent_comments, :subagent_comments, :source,
    :expr_date, :strt_date
    :findate


  def disabled?
    disabled || not_implemented || no_commission
  end

  def applicable? recommendation
    not disabled? and
    # carrier == recommendation.validating_carrier_iata and
    applicable_date? and
    applicable_interline?(recommendation) and
    valid_interline?(recommendation) and
    applicable_classes?(recommendation) and
    applicable_subclasses?(recommendation) and
    applicable_custom_check?(recommendation) and
    applicable_routes?(recommendation) and
    applicable_geo?(recommendation)
  end

  def applicable_interline? recommendation
    case interline
    when :possible
      not recommendation.interline? or
      recommendation.validating_carrier_participates?
    when nil, :no
      not recommendation.interline?
    when :yes
      recommendation.interline? and
      recommendation.validating_carrier_participates?
    when :absent
      recommendation.interline? and
      not recommendation.validating_carrier_participates?
    when :first
      recommendation.interline? and
      recommendation.validating_carrier_starts_itinerary?
    when :half, :unconfirmed
      recommendation.interline? and
      recommendation.validating_carrier_makes_half_of_itinerary?
    else
      raise ArgumentError, "неизвестный тип interline у #{carrier}: '#{interline}' (line #{source})"
    end
  end

  def valid_interline? recommendation
    Commission.skip_interline_validity_check || recommendation.valid_interline?
  end

  CLASS_CABIN_MAPPING = {:economy => %w(M W Y), :business => %w(C), :first => %w(F)}

  def applicable_classes? recommendation
    return true unless classes

    cabins = classes.each_with_object([]) {|c, a| a.push(*CLASS_CABIN_MAPPING[c])}
    (recommendation.cabins - cabins).blank?
  end

  def applicable_subclasses? recommendation
    return true unless subclasses
    (recommendation.booking_classes - subclasses).blank?
  end

  def applicable_custom_check? recommendation
    return true unless check
    recommendation.instance_eval &check
  end

  def applicable_geo? recommendation
    return true unless domestic || international
    raise "wtf?" if domestic && international
    domestic && recommendation.domestic? || international && recommendation.international?
  end

  def applicable_routes? recommendation
    return true unless routes
    routes.include? recommendation.route
  end

  def applicable_date?
    if expr_date
      return true unless expr_date.to_date.past?
    elsif strt_date
      return true unless strt_date.to_date.future?
    elsif !(expr_date && strt_date)
      return true
    end
  end

  def share(fare, tickets=1)
    # FIXME сделать поддержу EUR
    if subagent['%']
      fround(fare * subagent.to_f / 100)
    else
      fround(subagent.to_f)
    end
  end

  def consolidator_markup(fare, tickets=1)
    if share(fare) <= 5
      # особые условия для этих компаний.
      if %W( LH LX KL AF OS ).include? carrier
        fare * 0.01
      else
        fare * 0.02
      end
    else
      0
    end
  end

  def agent_percentage?
    agent['%']
  end

  def agent_euro?
    agent['eur']
  end

  def agent_value
    val = agent.to_f
    val *= euro_rate if agent_euro?
    val
  end

  #FIXME нужно починить для работы с валютой
  def euro_rate
    Conf.amadeus.euro_rate
  end

  def date_accords?(incoming_date)

	incoming_date = incoming_date.to_date
	if !startdate && !findate
		return true
	elsif startdate && findate
		localstartdate = startdate.to_date
		localfindate = findate.to_date
		if localstartdate <= incoming_date && incoming_date <= localfindate
			return true
		end
	elsif findate
		localfindate = findate.to_date
		if incoming_date <=localfindate
			return true
		end
	elsif startdate
		localstartdate = startdate.to_date
		if incoming_date >= localstartdate
			return true
		end
	end
  end

  private

  def fround x
    ('%.2f' % x.to_f).to_f
  end


  module ClassMethods

    mattr_accessor :opts
    mattr_accessor :skip_interline_validity_check
    mattr_accessor :commissions
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
      if commission.important
        commissions[@carrier].unshift commission
      else
        commissions[@carrier].push commission
      end
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

    # пока принимает уже готовый массив
    def routes routes
      opts[:routes] = routes
    end

    def subclasses *subclasses
      opts[:subclasses] = subclasses.join.upcase.gsub(' ', '').split('')
    end

    def classes *classes
      opts[:classes] = classes
    end

    def important!
      opts[:important] = true
    end

    def example str
      opts[:examples] ||= []
      opts[:examples] << [str, caller_address]
    end

    def check &block
      opts[:check] = block
    end

    def expr_date date
      opts[:expr_date] = date
    end

    def strt_date date
      opts[:strt_date] = date
    end

    # метод поиска рекомендации

    def find_for(recommendation)
      (commissions[recommendation.validating_carrier_iata] || return).find do |c|
        c.applicable?(recommendation)
      end
    end

    def exists_for?(recommendation)
      commissions[recommendation.validating_carrier_iata].present?
    end


    # test methods
     def test
      self.skip_interline_validity_check = true
      @check_date = Date.today
      commissions.values.flatten.sort_by {|c| c.source.to_i }.each do |commission|
        (commission.examples || next).each do |code, source|
          rec = Recommendation.example(code, :carrier => commission.carrier)
          proposed = find_for(rec)
          if commission.expr_date && commission.expr_date.to_date.past? && !commission.disabled?
            error "#{commission.carrier} (line #{source}): - expiration date passed!"
          elsif commission.strt_date && commission.strt_date.to_date.future? && !commission.disabled?
            error "#{commission.carrier} (line #{source}): - start date doesn't come!"
          elsif proposed == commission ||
                proposed.nil? && commission.disabled?
          if proposed == commission  ||
             (proposed.nil? && commission.disabled?)
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
      self.skip_interline_validity_check = false
      @check_date = nil
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


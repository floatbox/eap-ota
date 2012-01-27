# encoding: utf-8
module Commission::Rules

  def self.included base
    create_class_attrs base
    base.send :extend, ClassMethods
  end

  include KeyValueInit
  include Commission::Fx
  extend Commission::Attrs
  has_commission_attrs :agent, :subagent, :consolidator, :blanks, :discount, :our_markup

  attr_accessor :carrier,
    :disabled, :not_implemented, :no_commission,
    :interline, :domestic, :international, :classes, :subclasses,
    :routes,
    :departure, :departure_country, :important,
    :check, :examples, :agent_comments, :subagent_comments, :source,
    :expr_date, :strt_date,
    :system, :ticketing_method, :corrector, :number

  def disabled?
    disabled || not_implemented || no_commission
  end

  def applicable? recommendation
    !turndown_reason(recommendation)
  end

  def turndown_reason recommendation
    disabled? and return "правило отключено"
    # carrier == recommendation.validating_carrier_iata and
    applicable_date? or return "прошел/не наступил период действия"
    applicable_interline?(recommendation) or return "интерлайн/не интерлайн"
    valid_interline?(recommendation) or return "нет интерлайн договора между авиакомпаниями"
    applicable_classes?(recommendation) or return "не подходит класс бронирования"
    applicable_subclasses?(recommendation) or return "не подходит подкласс бронирования"
    applicable_custom_check?(recommendation) or return "не прошло дополнительную проверку"
    applicable_routes?(recommendation) or return "маршрут не в списке применимых"
    applicable_geo?(recommendation) or return "не тот тип МВЛ/ВВЛ"
    nil
  end

  def applicable_interline? recommendation
    interline.any? do |definition|
      case definition
      when :no
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
  end

  # чуточку расширенный аксессор
  def interline
    @interline.presence || [:no]
  end

  # надо использовать self.class.skip..., наверное
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
    !expired? && !future?
  end

  def expired?
    return unless expr_date
    expr_date.to_date.past?
  end

  def future?
    return unless strt_date
    strt_date.to_date.future?
  end

  def correct!
    Commission::Correctors.apply(self, corrector)
  end

  def self.create_class_attrs klass
    klass.instance_eval do
      cattr_accessor :opts
      cattr_accessor :skip_interline_validity_check
      cattr_accessor :commissions
      self.commissions = {}

      cattr_accessor :default_opts
      self.default_opts = {}

      cattr_accessor :carrier_default_opts
      self.carrier_default_opts = {}
    end
  end

  module ClassMethods

    ALLOWED_KEYS_FOR_DEFS = %W[ system ticketing_method consolidator blanks discount our_markup corrector disabled].map(&:to_sym)

    def defaults def_opts={}
      def_opts.to_options!.assert_valid_keys(ALLOWED_KEYS_FOR_DEFS)
      self.default_opts = def_opts
    end

    def carrier_defaults def_opts={}
      def_opts.to_options!.assert_valid_keys(ALLOWED_KEYS_FOR_DEFS)
      self.carrier_default_opts = def_opts
    end

    def carrier carrier, carrier_name=nil
      if carrier =~ /\A..\Z/
        @carrier = carrier
        @carrier_name = carrier_name
        self.opts={}
        self.carrier_default_opts={}
        @last_commission_number = 1
      else
        raise ArgumentError, "strange carrier: #{carrier}"
      end
    end

    # один аргумент, разделенный пробелами или /; или два аргумента
    def commission arg
      vals = arg.strip.split(/[ \/]+/, -1)
      if vals.size != 2
        raise ArgumentError, "strange commission: #{arg}"
      end

      commission = new({
        :carrier => @carrier,
        :agent => vals[0],
        :subagent => vals[1],
        :source => caller_address
      }.merge(opts).reverse_merge(carrier_default_opts).reverse_merge(default_opts))

      commission.correct!

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
      commission.number = @last_commission_number
      @last_commission_number += 1
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

    def not_implemented value=true
      opts[:not_implemented] = value
    end

    # правило интерлайна
    def interline *values
      # шорткат для interline без параметров
      values = [:yes] if values.empty?
      opts[:interline] = values
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

    # дополнительные опции, пока без обработки
    def system value
      opts[:system] = value
    end

    def ticketing_method value
      opts[:ticketing_method] = value
    end

    def consolidator value
      opts[:consolidator] = value
    end

    def blanks value
      opts[:blanks] = value
    end

    def discount value
      opts[:discount] = value
    end

    def our_markup value
      opts[:our_markup] = value
    end

    # метод поиска рекомендации

    def find_for(recommendation)
      all_for(recommendation).find do |c|
        c.applicable?(recommendation)
      end
    end

    def all_for(recommendation)
      for_carrier(recommendation.validating_carrier_iata) || []
    end

    def exists_for?(recommendation)
      for_carrier(recommendation.validating_carrier_iata).present?
    end

    def for_carrier(validating_carrier_iata)
      commissions[validating_carrier_iata]
    end

    def all
      commissions.values.flatten.sort_by {|c| c.source.to_i }
    end

    def all_with_reasons_for(recommendation)
      found = nil
      all_for(recommendation).map do |c|
        reason = c.turndown_reason(recommendation)
        status =
          if !found && reason
            :fail
          elsif !found && !reason
            :success
          else
            :skipped
          end
        found = c unless reason
        [c, status, reason]
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

    def caller_address level=1
      caller[level] =~ /:(\d+)/
      $1 || 'unknown'
    end

  end

end


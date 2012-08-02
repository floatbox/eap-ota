# encoding: utf-8
module Commission::Reader

  extend ActiveSupport::Concern

  included do
    cattr_accessor :commissions
    self.commissions = {}

    cattr_accessor :opts
    cattr_accessor :default_opts
    cattr_accessor :carrier_default_opts
    self.default_opts = {}
    self.carrier_default_opts = {}
  end

  def correct!
    Commission::Correctors.apply(self, corrector)
  end


  module ClassMethods

    ALLOWED_KEYS_FOR_DEFS = %W[
      system ticketing_method consolidator blanks discount our_markup
      corrector disabled not_implemented no_commission
    ].map(&:to_sym)

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
    def no_commission(reason=true)
      # opts здесь по идее содержит только examples
      commission = new({
        :carrier => @carrier,
        :source => caller_address,
        :no_commission => reason
      }.merge(opts).reverse_merge(carrier_default_opts).reverse_merge(default_opts))

      # FIXME временно выключаю, потому что корректоры у нас пока работают только с числами
      # а их тут нет.
      # commission.correct!

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

    # Inspection
    ############

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

    def all_carriers
      commissions.keys.uniq
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

# encoding: utf-8
class Commission
  class Formula

    attr_accessor :formula

    def initialize formula
      @formula = formula.to_s.strip
    end

    def complex?
      !!formula['+']
    end

    def percentage?
      raise ArgumentError, "#{formula} contains several parts" if complex?
      !!formula['%']
    end

    def zero?
      rate.zero?
    end

    delegate :blank?, :to => :formula

    def euro?
      raise ArgumentError, "#{formula} contains several parts" if complex?
      !!formula['eur']
    end

    def rate
      raise ArgumentError, "#{formula} contains several parts" if complex?
      formula.to_f
    end

    def to_s
      formula
    end

    def inspect
      "#<Fx #{formula} >"
    end

    def call(base=nil, params={:eur => Conf.amadeus.euro_rate})
      raise ArgumentError, "formula '#{@formula}' is not valid" unless valid?
      multiplier = (params[:multiplier] || 1).to_i

      if complex?
        # FIXME horribly inefficcient
        formula.split('+').map do |f|
          Commission::Formula.new(f).call(base, params)
        end.inject(:+)

      elsif percentage?
        rate * base / 100

      elsif euro?
        rate * params[:eur].to_f * multiplier

      else
        rate * multiplier

      end.round(2)
    end

    alias [] call

    def valid?
      formula.blank? ||
      !!( formula.strip =~ /^ \d+ (?: \.\d+ )? (?: % | eur )?
                ( \s* \+ \s*  \d+ (?: \.\d+ )? (?: % | eur )? )*  $/x )
    end

    def == other_formula
      formula == other_formula.formula
    end


    # FIXME не работает. хочется чтоб было
    # -- eviterra.com,2011:commission/fx 2.3% + 50
    # или что-то типа.
    #
    # def to_yaml_type; '!eviterra.com,2011/commission/fx' end
    #
    # yaml_as "tag:eviterra.com,2011:commission/fx"
    # YAML.add_domain_type 'eviterra.com,2011', 'commission/fx' do |type, val|
    #   Commission::Formula.new(val)
    # end

    # def to_yaml( opts = {} )
    #   YAML.quick_emit( self, opts ) do |out|
    #     out.scalar( taguri, formula.to_s)
    #     # out.scalar( taguri ) do |sc|
    #     #  sc.embed( formula.to_s )
    #     #end
    #   end
    # end

  end
end

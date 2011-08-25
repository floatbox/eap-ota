# encoding: utf-8
class Commission
  class Formula

    attr_accessor :formula

    def initialize formula
      @formula = formula.to_s
    end

    def percentage?
      !!formula['%']
    end

    def euro?
      !!formula['eur']
    end

    def rate
      formula.to_f
    end

    def to_s
      formula
    end

    def call(base=nil, params={:eur => Conf.amadeus.euro_rate})
      multiplier = (params[:multiplier] || 1).to_i
      if percentage?
        rate * base / 100
      elsif euro?
        rate * params[:eur].to_f * multiplier
      else
        rate * multiplier
      end.round(2)
    end

    alias [] call

    def valid?
      !!( formula.strip =~ /^ \d+ (?: \.\d+ )? (?: % | eur )? $/x )
    end

    def == other_formula
      formula == other_formula.formula
    end


    # FIXME не работает. хочется чтоб было
    # -- eviterra.com,2011:commission/fx 2.3% + 50
    # или что-то типа.
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

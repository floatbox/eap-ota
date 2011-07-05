# encoding: utf-8
class Commission
  class Formula

    attr_accessor :formula

    def initialize formula
      @formula = formula
    end

    def percentage?
      formula['%']
    end

    def currency?
      formula['eur']
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
      elsif currency?
        rate * params[:eur].to_f * multiplier
      else
        rate * multiplier
      end
    end

    alias [] call

    def valid?
      !!( formula.strip =~ /^ \d+ (?: \.\d+ )? (?: % | eur )? $/x )
    end

  end
end

# encoding: utf-8
class Commission
  module Fx
    def Fx(formula_spec)
      Commission::Formula.new(formula_spec)
    end
  end
end

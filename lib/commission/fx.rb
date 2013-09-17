# encoding: utf-8
#
# хелпер, для тех, кому лениво писать Commission::Formula.new
module Commission::Fx
  def Fx(*formula_spec)
    Commission::Formula.new(*formula_spec)
  end
end

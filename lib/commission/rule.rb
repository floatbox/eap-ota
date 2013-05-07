# encoding: utf-8
#
# комиссионное правило. Просто тупой контейнер для параметров правила.
class Commission::Rule

  include Commission::Matching

  include KeyValueInit
  extend Commission::Attrs

  has_commission_attrs :agent, :subagent, :consolidator, :blanks, :discount, :our_markup

  attr_accessor :carrier,
    :disabled, :not_implemented, :no_commission,
    :interline, :domestic, :international, :classes, :subclasses,
    :routes,
    :departure, :departure_country, :important,
    :check, :agent_comments, :subagent_comments, :tour_code, :source,
    :expr_date, :strt_date,
    :system, :ticketing_method, :corrector, :number

  attr_reader :examples

  # чуточку расширенный аксессор
  # FIXME заменить дефолтами в initialize(*)
  def interline
    @interline.presence || [:no]
  end

  def examples=(example_array)
    @examples = example_array.collect do |code, source|
      Commission::Example.new( code: code, source: source, commission: self )
    end
  end

  def inspect
    "<commission #{carrier}##{number} :#{source}>"
  end

  # FIXME документировать
  def correct!
    Commission::Correctors.apply(self, corrector)
  end

end

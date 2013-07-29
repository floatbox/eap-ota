# encoding: utf-8
#
# хранит в себе пример рекомендации,
# проверяет правильность комиссионного правила.
class Commission::Example

  include KeyValueInit
  attr_accessor :source, :commission, :code

  def recommendation
    @rec ||= Recommendation.example(code, :carrier => commission.carrier)
  end

  def to_s
    code
  end

  def inspect
    "<example '#{code}' at #{source}>"
  end

end

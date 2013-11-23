# encoding: utf-8
#
# сборник скидочных правил
# умеют подбирать скидку по рекомендации (и контексту)
# сейчас действует аналогично Commission::Section - выбирает набор исходя из текущей даты

class Discount::Book

  def initialize
    @index = []
  end

  def register start_time, &block
    @index << [start_time, block]
    @index.sort_by! &:first
    if @index.uniq.size != @index.size
      raise ArgumentError, "discounts for #{start_time} already registered."
    end
  end

end

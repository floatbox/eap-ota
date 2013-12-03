# encoding: utf-8
#
# сборник скидочных правил
# умеют подбирать скидку по рекомендации (и контексту)
# сейчас действует аналогично Commission::Section - выбирает набор исходя из текущей даты

class Discount::Book
  def self.default_book
    @book ||= new
  end

  def initialize
    @index = []
  end

  def register start_date, definition
    section = Discount::Section.new start_date, definition
    @index << [start_date, section]
    @index.sort_by! &:first
    if @index.uniq.size != @index.size
      raise ArgumentError, "discounts for #{start_time} already registered."
    end
  end

  def find_rule_for_rec rec, opts = {}
    @index.first.last.find_rule_for_rec rec, opts
  end
end

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
    section = Discount::Section.new Date.parse(start_date), definition
    @index << section
    @index.sort_by! {|s| s.start_date}
    if @index.uniq.size != @index.size
      raise ArgumentError, "discounts for #{start_time} already registered."
    end
  end

  def find_rule_for_rec rec, opts = {}
    section = current_section
    section.find_rule_for_rec rec, opts
  end

  def current_section date = Date.today
    s = @index.find {|section| section.start_date <= date}
    raise Discount::SectionNotFound unless s
    s
  end
end

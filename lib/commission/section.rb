# encoding: utf-8
#
# Сборник комиссионных правил для перевозчика и метода выписки.
# Содержит одну или несколько страниц для разных дат, умеет выбирать
# актуальную для даты
class Commission::Section

  include KeyValueInit

  # @return String IATA код перевозчика
  attr_accessor :carrier

  # @return String метод выписки для правил
  attr_accessor :ticketing_method

  def initialize(*)
    @index = []
    super
  end

  def pages
    @index
  end

  def current_page(date=Date.today)
    pages.find {|p| p.start_date.nil? || p.start_date <= date }
  end

  LONG_TIME_AGO = Date.new(1,1,1)
  def register_page(page)
    pages = @index.dup
    pages << page
    pages.sort_by! {|p| p.start_date || LONG_TIME_AGO }
    pages.reverse!
    if pages.map(&:start_date).uniq.size != pages.size
      raise ArgumentError, "#{page} with #{page.start_date} already registered"
    end
    @index = pages
    page
  end

  # not used yet
  def obsolete_page?(page)
    return false if current_page == page || current_page.start_date.nil?
    return true if page.start_date.nil?
    return page.start_date < current_page.start_date
  end

end

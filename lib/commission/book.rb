# encoding: utf-8
#
# сборник комиссионных правил
# умеют подбирать комиссию по рекомендации
class Commission::Book

  def initialize
    @index = {}
  end

  # Inspection
  ############

  def rules
    pages.flat_map(&:rules).sort_by(&:source)
  end

  def carriers
    @index.keys
  end

  def pages
    sections.flat_map(&:pages)
  end

  def sections
    @index.values.flat_map(&:values)
  end

  # FIXME отдает страницы только по одному методу выписки
  # нужен ли еще?
  def pages_for(opts)
    section = find_section(opts) or return
    section.pages
  end

  def current_pages(date=Date.today)
    sections.map {|s| s.current_page(date) }.compact
  end

  def current_rules(date=Date.today)
    current_pages(date).flat_map(&:rules)
  end

  # Recommendation finders
  ########################

  # принимает список ticketing_method-ов
  def find_rules_for_rec(recommendation, opts={})
    carrier = recommendation.validating_carrier_iata
    ticketing_methods = Array(opts[:ticketing_method] || @index[carrier].try(&:keys))
    sections = ticketing_methods.map {|m| find_section(carrier: carrier, ticketing_method: m) }.compact
    pages = sections.map {|s| s.current_page }.compact
    pages.map {|p| p.find_rule_for_rec(recommendation) }.compact
  end

  # выбирает страницу с указанным перевозчиком
  # по умолчанию - действующую в данный момент
  def find_page(opts)
    section = find_section(opts) or return
    date = opts[:date] || Date.today
    page = section.current_page(date)
  end

  # создает и вносит в индекс страницу
  # @return Commission::Page
  def create_page(opts)
    page = Commission::Page.new opts
    register_page page
  end

  # вносит в индекс страницу
  # @return Commission::Page
  def register_page(page)
    section = find_or_create_section(carrier: page.carrier, ticketing_method: page.ticketing_method)
    section.register_page(page)
  end

  def find_section(opts)
    carrier = opts[:carrier]
    ticketing_method = opts[:ticketing_method] || "unknown"
    @index[carrier] && @index[carrier][ticketing_method]
  end

  def find_or_create_section(opts)
    carrier = opts[:carrier]
    ticketing_method = opts[:ticketing_method] || "unknown"
    @index[carrier] ||= {}
    @index[carrier][ticketing_method] ||=
      Commission::Section.new(carrier: carrier, ticketing_method: ticketing_method)
  end

  def all_with_reasons_for(recommendation)
    page = find_page(carrier: recommendation.validating_carrier_iata) or return []
    page.all_with_reasons_for(recommendation)
  end

end

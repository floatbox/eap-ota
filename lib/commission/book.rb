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

  def exists_for?(recommendation)
    pages_for(carrier: recommendation.validating_carrier_iata).present?
  end

  def rules
    pages.map(&:rules).flatten.sort_by(&:source)
  end

  def carriers
    @index.keys
  end

  def pages
    @index.values.map(&:values).flatten
  end

  def pages_for(opts)
    carrier = opts[:carrier] or raise ArgumentError, "carrier not specified"
    ticketing_method = opts[:ticketing_method] || "unknown"
    @index[carrier] && @index[carrier][ticketing_method]
  end

  # временный метод, отображающий только активные страницы
  def current_pages
    carriers.map do |carrier|
      find_page(carrier: carrier)
    end
  end

  # Recommendation finders
  ########################

  def find_for(recommendation)
    page = find_page(carrier: recommendation.validating_carrier_iata) or return Commission::Rule::Null
    page.find_rule(recommendation) or return Commission::Rule::Null
  end

  # выбирает страницу с указанным перевозчиком
  # по умолчанию - действующую в данный момент
  def find_page(opts)
    pages = pages_for(opts) or return
    date = opts[:date] || Date.today
    page = pages.find {|p| p.start_date.nil? || p.start_date <= date }
  end

  # создает и вносит в индекс страницу
  # @return Commission::Page
  def create_page(opts)
    page = Commission::Page.new opts
    register_page page
  end

  LONG_TIME_AGO = Date.new(2000,1,1)
  # вносит в индекс страницу
  # TODO ugly and untested
  # @return Commission::Page
  def register_page(page)
    carrier = page.carrier
    ticketing_method = page.ticketing_method || "unknown"
    @index[carrier] ||= {}
    pages = @index[carrier][ticketing_method] || []
    pages += [page]
    pages.sort_by! {|p| p.start_date || LONG_TIME_AGO }
    pages.reverse!
    if pages.map(&:start_date).uniq.size != pages.size
      raise ArgumentError, "#{page} with #{page.start_date} already registered in book"
    end
    @index[carrier][ticketing_method] = pages
    page
  end

  def all_with_reasons_for(recommendation)
    page = find_page(carrier: recommendation.validating_carrier_iata) or return []
    page.all_with_reasons_for(recommendation)
  end
end

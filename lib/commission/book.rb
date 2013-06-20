# encoding: utf-8
#
# сборник комиссионных правил
# умеют подбирать комиссию по рекомендации
class Commission::Book

  def initialize
    @index = {}
  end

  # Добавляет комиссию в соответствующую книгу. Создает новую книгу, если надо.
  def register commission
    page = find_or_create_page commission
    page.register commission
  end

  # Inspection
  ############

  def all_for(recommendation)
    for_carrier(recommendation.validating_carrier_iata) || []
  end

  def exists_for?(recommendation)
    for_carrier(recommendation.validating_carrier_iata).present?
  end

  def for_carrier(validating_carrier_iata)
    page = @index[validating_carrier_iata] or return
    page.commissions
  end

  # Временный метод для получения диапазонов действия комиссий
  def start_dates_for_carrier(validating_carrier_iata)
    ( for_carrier(validating_carrier_iata).map {|c| c.strt_date }.compact +
      for_carrier(validating_carrier_iata).map {|c| c.expr_date }.compact.map(&:tomorrow)
    ).sort.uniq
  end

  def all
    pages.map(&:all).flatten.sort_by {|c| c.source.to_i }
  end

  def all_carriers
    @index.keys
  end

  def pages
    @index.values
  end

  # Recommendation finders
  ########################

  def find_for(recommendation)
    page = find_page(recommendation) or return
    page.find_commission(recommendation)
  end

  def find_page(recommendation)
    @index[recommendation.validating_carrier_iata]
  end

  def find_page_for_commission(commission)
    @index[commission.carrier]
  end

  # создает и вносит в индекс страницу, подходящую для переданной комиссии
  def create_page(commission)
    page = Commission::Page.new carrier: commission.carrier
    register_page page
  end

  # вносит в индекс страницу
  def register_page(page)
    @index[page.carrier] = page
  end

  def find_or_create_page(commission)
    find_page_for_commission(commission) || create_page(commission)
  end

  def all_with_reasons_for(recommendation)
    page = find_page(recommendation) or return []
    page.all_with_reasons_for(recommendation)
  end
end

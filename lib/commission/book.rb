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

  def all
    pages.map(&:all).flatten.sort_by {|c| c.source.to_i }
  end

  def carriers
    @index.keys
  end

  def pages
    @index.values.flatten
  end

  def pages_for(opts)
    carrier = opts[:carrier] or raise ArgumentError "carrier not specified"
    @index[carrier]
  end

  # Recommendation finders
  ########################

  def find_for(recommendation)
    page = find_page(carrier: recommendation.validating_carrier_iata) or return []
    page.find_commission(recommendation)
  end

  # выбирает активную страницу для
  # FIXME выбирает активну
  def find_page(opts)
    pages = pages_for(opts) or return
    page = pages.reverse.find {|p| p.strt_date.nil? || p.strt_date <= Date.today }
  end

  # создает и вносит в индекс страницу
  # @return Commission::Page
  def create_page(opts)
    page = Commission::Page.new opts
    register_page page
  end

  # вносит в индекс страницу
  # TODO должно орать громким голосом, если две страницы имеют одну и ту же дату
  # @return Commission::Page
  def register_page(page)
    @index[page.carrier] ||= []
    @index[page.carrier] << page
    page
  end

  def all_with_reasons_for(recommendation)
    page = find_page(carrier: recommendation.validating_carrier_iata) or return []
    page.all_with_reasons_for(recommendation)
  end
end

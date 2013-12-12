module Admin
  class TicketsPresenter
    include ActionView::Helpers::NumberHelper

    attr_reader :scope

    def initialize scope
      @scope = scope
    end

    def total_price
      as_currency counters.s_total_price
    end

    def average_price
      as_currency counters.a_average_price
    end

    private

    def as_currency value
      number_to_currency value, locale: :ru
    end

    def counters
      @counters ||= scope.select(%|
        SUM(price_fare) AS s_total_price,
        AVG(price_fare) AS a_average_price
      |).first
    end
  end
end

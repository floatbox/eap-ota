module Admin
  class OrdersPresenter
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

    def income
      as_currency counters.s_income
    end

    private

    def as_currency value
      number_to_currency value, locale: :ru
    end

    def counters
      @counters ||= scope.select(%|
        SUM(price_with_payment_commission) AS s_total_price,
        AVG(price_with_payment_commission) AS a_average_price,
        SUM(stored_income) AS s_income
      |).first
    end
  end
end

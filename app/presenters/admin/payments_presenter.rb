module Admin
  class PaymentsPresenter
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

    def total_earnings
      as_currency counters.s_total_earnings
    end

    def average_earnings
      as_currency counters.s_average_earnings
    end

    private

    def as_currency value
      number_to_currency value, locale: :ru
    end

    def counters
      @counters ||= scope.select(%|
        SUM(price) AS s_total_price,
        AVG(price) AS a_average_price,
        SUM(earnings) AS s_total_earnings,
        AVG(earnings) AS s_average_earnings,
        1 as status
      |).first
    end
  end
end

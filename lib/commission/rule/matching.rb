# encoding: utf-8
#
# методы для Commission::Rule, для проверки применимости
# конкретного правила к конкретной рекомендации
module Commission::Rule::Matching

  extend ActiveSupport::Concern

  # можно ли показывать клиентам и продавать предложения
  # по данному комиссинному правилу?
  # TODO Переместить в другой модуль?
  def sellable?
    !disabled?
  end

  def disabled?
    disabled || not_implemented || no_commission
  end

  def skipped?
    disabled || not_implemented
  end

  def applicable? recommendation
    !turndown_reason(recommendation)
  end

  def turndown_reason recommendation
    skipped?                                and return :skipped     # "правило не проверяется"
    # carrier == recommendation.validating_carrier_iata and
    applicable_interline?(recommendation)    or return :interline   # "интерлайн/не интерлайн"
    applicable_classes?(recommendation)      or return :classes     # "не подходит класс бронирования"
    applicable_subclasses?(recommendation)   or return :subclasses  # "не подходит подкласс бронирования"
    applicable_custom_check?(recommendation) or return :check       # "не прошло дополнительную проверку"
    applicable_routes?(recommendation)       or return :routes      # "маршрут не в списке применимых"
    applicable_geo?(recommendation)          or return :geo         # "не тот тип МВЛ/ВВЛ"
    nil
  end

  def applicable_interline? recommendation
    interline.any? do |definition|
      case definition
      when :no
        not recommendation.interline?
      when :no_codeshare
        not recommendation.interline? and
        not recommendation.codeshare?
      when :yes, :unconfirmed
        recommendation.interline? and
        recommendation.validating_carrier_participates?
      when :absent
        recommendation.interline? and
        not recommendation.validating_carrier_participates?
      when :first
        recommendation.interline? and
        recommendation.validating_carrier_starts_itinerary?
      when :half
        recommendation.interline? and
        recommendation.validating_carrier_makes_half_of_itinerary?
      when :less_than_half
        recommendation.interline? and
        recommendation.validating_carrier_makes_more_than_half_of_itinerary?
      end
    end
  end

  CLASS_CABIN_MAPPING = {:economy => %w(M W Y), :business => %w(C), :first => %w(F)}

  def applicable_classes? recommendation
    return true unless classes

    cabins = classes.each_with_object([]) {|c, a| a.push(*CLASS_CABIN_MAPPING[c])}
    (recommendation.cabins - cabins).blank?
  end

  def applicable_subclasses? recommendation
    return true unless subclasses
    (recommendation.booking_classes - subclasses).blank?
  end

  def applicable_custom_check? recommendation
    return true unless check_proc
    recommendation.instance_eval &check_proc
  end

  def applicable_geo? recommendation
    return true unless domestic || international
    domestic && recommendation.domestic? || international && recommendation.international?
  end

  def applicable_routes? recommendation
    return true unless routes
    route = recommendation.route
    compiled_routes.any? {|routex| routex === route }
  end

end

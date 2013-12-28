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
    case
    when skipped?                                   then :skipped     # "правило не проверяется"
    when ! applicable_interline?(recommendation)    then :interline   # "интерлайн/не интерлайн"
    when ! applicable_classes?(recommendation)      then :classes     # "не подходит класс бронирования"
    when ! applicable_subclasses?(recommendation)   then :subclasses  # "не подходит подкласс бронирования"
    when ! applicable_custom_check?(recommendation) then :check       # "не прошло дополнительную проверку"
    when ! applicable_routes?(recommendation)       then :routes      # "маршрут не в списке применимых"
    when ! applicable_geo?(recommendation)          then :geo         # "не тот тип МВЛ/ВВЛ"
    end
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
    ( compiled_positive_routes.empty? ||
      compiled_positive_routes.any? {|routex| routex === route }
    ) && compiled_negative_routes.none? {|routex| routex === route }
  end

end

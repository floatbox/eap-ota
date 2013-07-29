# encoding: utf-8
#
# методы для Commission::Rule, для проверки применимости
# конкретного правила к конкретной рекомендации
module Commission::Rule::Matching

  extend ActiveSupport::Concern

  included do
    cattr_accessor :skip_interline_validity_check
  end

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
    skipped? and return "правило не проверяется"
    # carrier == recommendation.validating_carrier_iata and
    applicable_interline?(recommendation) or return "интерлайн/не интерлайн"
    valid_interline?(recommendation) or return "нет интерлайн договора между авиакомпаниями"
    applicable_classes?(recommendation) or return "не подходит класс бронирования"
    applicable_subclasses?(recommendation) or return "не подходит подкласс бронирования"
    applicable_custom_check?(recommendation) or return "не прошло дополнительную проверку"
    applicable_routes?(recommendation) or return "маршрут не в списке применимых"
    applicable_geo?(recommendation) or return "не тот тип МВЛ/ВВЛ"
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
      else
        raise ArgumentError, "неизвестный тип interline у #{carrier}: '#{interline}' (line #{source})"
      end
    end
  end

  # надо использовать self.class.skip..., наверное
  def valid_interline? recommendation
    Commission::Rule.skip_interline_validity_check || recommendation.valid_interline?
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
    raise "wtf?" if domestic && international
    domestic && recommendation.domestic? || international && recommendation.international?
  end

  def applicable_routes? recommendation
    return true unless routes
    route = recommendation.route
    compiled_routes.any? {|routex| routex === route }
  end

end

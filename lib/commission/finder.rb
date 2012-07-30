# encoding: utf-8
# поиск комиссий для рекомендации
module Commission::Finder

  extend ActiveSupport::Concern

  included do
    cattr_accessor :skip_interline_validity_check
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
    applicable_date? or return "прошел/не наступил период действия"
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
      else
        raise ArgumentError, "неизвестный тип interline у #{carrier}: '#{interline}' (line #{source})"
      end
    end
  end

  # надо использовать self.class.skip..., наверное
  def valid_interline? recommendation
    Commission.skip_interline_validity_check || recommendation.valid_interline?
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
    return true unless check
    recommendation.instance_eval &check
  end

  def applicable_geo? recommendation
    return true unless domestic || international
    raise "wtf?" if domestic && international
    domestic && recommendation.domestic? || international && recommendation.international?
  end

  def applicable_routes? recommendation
    return true unless routes
    routes.include? recommendation.route
  end

  def applicable_date?
    !expired? && !future?
  end

  def expired?
    return unless expr_date
    expr_date.to_date.past?
  end

  def future?
    return unless strt_date
    strt_date.to_date.future?
  end


  module ClassMethods

    def find_for(recommendation)
      commission = all_for(recommendation).find do |c|
        c.applicable?(recommendation)
      end
      return unless commission
      return if commission.disabled?
      commission
    end

    def all_with_reasons_for(recommendation)
      found = nil
      all_for(recommendation).map do |c|
        reason = c.turndown_reason(recommendation)
        status =
          if !found && reason
            :fail
          elsif !found && !reason
            :success
          else
            :skipped
          end
        found = c unless reason
        [c, status, reason]
      end
    end

  end

end

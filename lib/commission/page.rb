# encoding: utf-8

# контейнер для набора комиссий, работающих вместе,
# имеющих общий диапазон дат применимости, валидирующего перевозчика,
# и, однажды, офис выписки.
# умеет подбирать комиссию под рекомендацию.
class Commission::Page

  include KeyValueInit

  # @return Array<Commission::Rule> список правил (в порядке обсчета)
  attr_accessor :commissions

  # @return String IATA код перевозчика
  attr_accessor :carrier

  # @return Date дата начала действия комиссии
  attr_accessor :start_date

  def initialize(*)
    @commissions = []
    super
  end

  # создает и вносит в книгу комиссию
  def create_rule(attrs)
    commission = Commission::Rule.new(attrs)
    register commission
  end

  # вносит в книгу готовую комиссию
  def register commission
    commission.number = commissions.size + 1
    if commission.important
      commissions.unshift commission
    else
      commissions.push commission
    end
    commission
  end

  # Inspection
  ############

  # @return Array<Commission::Rule> список правил (в порядке ввода/документа)
  def all
    commissions.sort_by {|c| c.source.to_i }
  end

  # @return Boolean есть ли хоть одна (включенная) комиссия?
  def empty?
    commissions.all?(&:disabled?)
  end

  def ticketing_methods
    commissions.reject(&:disabled?).collect(&:ticketing_method).uniq.sort
  end

  # Recommendation finders
  ########################

  def find_commission(recommendation)
    commission = commissions.find do |c|
      c.applicable?(recommendation)
    end
    return unless commission
    return if commission.disabled?
    commission
  end

  # Применяет каждое правило в странице к рекомендации.
  # Объясняет, почему не сработало.
  def all_with_reasons_for(recommendation)
    found = nil
    commissions.map do |c|
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

# encoding: utf-8

# контейнер для набора комиссий, работающих вместе,
# имеющих общий диапазон дат применимости, валидирующего перевозчика,
# и, однажды, офис выписки.
# умеет подбирать комиссию под рекомендацию.
class Commission::Page

  include KeyValueInit

  # @return String IATA код перевозчика
  attr_accessor :carrier

  # @return Date дата начала действия комиссии
  attr_accessor :start_date

  def initialize(*)
    @index = []
    super
  end

  # создает и вносит в книгу комиссию
  def create_rule(attrs)
    rule = Commission::Rule.new(attrs)
    register rule
  end

  # вносит в книгу готовую комиссию
  def register rule
    rule.number = @index.size + 1
    if rule.important
      @index.unshift rule
    else
      @index.push rule
    end
    rule
  end

  # Inspection
  ############

  # @return Array<Commission::Rule> список правил (в порядке ввода/документа)
  def rules
    @index.sort_by(&:number)
  end

  # @return Boolean есть ли хоть одна (включенная) комиссия?
  def empty?
    @index.all?(&:disabled?)
  end

  def ticketing_methods
    @index.reject(&:disabled?).collect(&:ticketing_method).uniq.sort
  end

  # Recommendation finders
  ########################

  def find_rule(recommendation)
    @index.find do |r|
      r.applicable?(recommendation)
    end
  end

  # Применяет каждое правило в странице к рекомендации.
  # Объясняет, почему не сработало.
  def all_with_reasons_for(recommendation)
    found = nil
    @index.map do |r|
      reason = r.turndown_reason(recommendation)
      status =
        if !found && reason
          :fail
        elsif !found && !reason
          :success
        else
          :skipped
        end
      found = r unless reason
      [r, status, reason]
    end
  end
end

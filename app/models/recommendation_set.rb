# encoding: utf-8

class RecommendationSet

  delegate  :empty?,
            :present?,
            :blank?,
            :size,
            :count,
            :flights,
            :first,
            :last,
            :map,
            :map!,
            :collect,
            :select,
            :reject,
            :select!,
            :reject!,
            :delete_if,
            :uniq!,
            :flat_map,
            :flatten,
            :segments,
            :variants,
            :[],
    to: :recommendations


  def initialize(recommendations=Array.new)
    @recommendations = recommendations
  end

  def recommendations
    @recommendations
  end

  def to_a
    @recommendations
  end

  def each &block
    @recommendations.each &block
  end

  def + other
    @recommendations += case other
      when Array then other
      when RecommendationSet then other.recommendations
      else raise TypeError, "cannot concatenate #{other.class} with RecommendationSet"
    end
    self
  end

  def to_s
    "#{super}: #{@recommendations.to_s}"
  end

  def << other
    @recommendations << other
    self
  end

  def select_valid!
    select_by! :full_information?, :valid_interline?
    reject_by! :ignored_carriers
    yield(@recommendations) if block_given?
    # чистка - пока что могут оставаться рекомендации без вариантов
    @recommendations.select! &:variants?
    self
  end

  def sort_by &block
    RecommendationSet.new(@recommendations.sort_by &block)
  end

  def filters_data
    Recommendation.filters_data @recommendations
  end

  def find_commission!
    @recommendations.each(&:find_commission!)
  end

  # бывший Recommendation#corrected - там ему больше не место
  def group_and_correct
    result = RecommendationSet.new
    #объединяем эквивалентные варианты
    @recommendations.each do |r|
      #некрасиво, но просто и работает
      if r.groupable_with? result[-1]
        result[-1].variants += r.variants
      elsif r.groupable_with? result[-2]
        result[-2].variants += r.variants
      elsif r.groupable_with? result[-3]
        result[-3].variants += r.variants
      else
        result << r
      end
    end
    result
  end

  private

  def reject_by! *criterias
    criterias.each { |criteria| reject!(&criteria) }
  end

  def select_by! *criterias
    criterias.each { |criteria| select!(&criteria) }
  end

end


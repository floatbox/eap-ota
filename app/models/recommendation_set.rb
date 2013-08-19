# encoding: utf-8

class RecommendationSet

  delegate  :empty?,
            :present?,
            :blank?,
            :each,
            :size,
            :count,
            :flights,
            :first,
            :last,
            :map,
            :collect,
            :select,
            :reject,
            :flat_map,
            :flatten,
            :segments,
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

  def + other
    @recommendations += other.recommendations
    self
  end

  def to_s
    "#{super}: #{@recommendations.to_s}"
  end

  [:<<, :delete_if, :map!, :reject!, :select!, :uniq!].each do |method|
    class_eval <<-EOS, __FILE__, __LINE__ - 2
      def #{method} *args
        @recommendations.#{method}(*args)
        self
      end
    EOS
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


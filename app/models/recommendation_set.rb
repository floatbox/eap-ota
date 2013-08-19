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

  def select_valid!
    select_by! :full_information?, :valid_interline?
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

  [:<<, :delete_if, :map!, :reject!, :select!, :uniq!].each do |method|
    class_eval <<-EOS, __FILE__, __LINE__ - 2
      def #{method} *args
        @recommendations.#{method}(*args)
        self
      end
    EOS
  end

  private

  def reject_by! *criterias
    criterias.each { |criteria| reject!(&criteria) }
  end

  def select_by! *criterias
    criterias.each { |criteria| select!(&criteria) }
  end

end


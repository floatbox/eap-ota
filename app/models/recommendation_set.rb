# encoding: utf-8

class RecommendationSet < Struct.new(:recommendations)

  delegate  :empty?,
            :size,
            :count,
            :flights,
            :first,
            :last,
    to: :recommendations

  # вынести это отсюда нафиг
  [:<<, :delete_if, :reject!, :select!, :+, :-].each do |method|
    class_eval <<-EOS, __FILE__, __LINE__ - 1
      def #{method} *args
        @recommendations.#{method}(*args)
        self
      end
    EOS
  end

  def to_s
    "#{super}: #{@recommendations.to_s}"
  end

  def reject_invalid!
    reject_by! :without_full_information?, :invalid_interline?
  end

  private

  def reject_by! *criterias
    criterias.each { |criteria| reject!(&criteria) }
  end

  def select_by! *criterias
    criterias.each { |criteria| reject!(&criteria) }
  end

end

class Discount::Section
  class Evaluator
    attr_accessor :recommendation, :commission, :context, :definition
    include KeyValueInit
    include Commission::Fx
    def find_rule
      rule = instance_eval &definition
    end

    private

    def our_markup value
      Discount::Rule.new our_markup: value
    end

    def discount value
      Discount::Rule.new discount: value
    end

    def netto value
      Discount::Rule.netto commission, value
    end

    def scaled value
      Discount::Rule.scaled commission, value
    end
  end

  attr_reader :start_time, :definition

  def initialize start_time, definition
    @start_time = start_time
    @definition = definition
  end

  def find_rule_for_rec recommendation, opts = {}
    context = opts[:context]
    commission = recommendation.commission
    evaluator = Evaluator.new(
      recommendation: recommendation,
      context:        context,
      commission:     commission,
      definition:     definition
    )
    rule = evaluator.find_rule
    rule || Discount::Rule.zero
  end
end

class Commission
  class Example
    include KeyValueInit
    attr_accessor :source, :commission, :code

    def recommendation
      @rec ||= Recommendation.example(code, :carrier => commission.carrier)
    end

    def to_s
      code
    end

    def inspect
      "<example '#{code}' :#{source}>"
    end

  end
end

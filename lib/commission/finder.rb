class Commission::Finder

  def initialize(book=Commission.default_book)
    @book = book
  end

  def cheap!(rec, opts={})
    rules = @book.find_rules_for_rec(rec, opts).select(&:sellable?)
    best_rule = rules.min_by do |rule|
      # side effect!
      rec.commission = rule
      rec.price_total
    end
    rec.commission = best_rule || Commission::Rule::Null
  end

end

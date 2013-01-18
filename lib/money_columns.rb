# encoding: utf-8
module MoneyColumns
  extend ActiveSupport::Concern
  MONEY_VALIDATION_REGEXP = / \d+ (?:.\d{2})? \s* (?:USD|EUR|RUB) $/x

  def has_money_columns *columns
    money_columns = columns.every.to_sym
    money_columns.each do |column|
    composed_of column,
      :class_name => 'Money',
      :mapping => [[column.to_s + '_cents', 'cents'], [column.to_s + '_currency', 'currency_as_string']],
      :constructor => Proc.new { |original_tax_cents, original_tax_currency| original_tax_cents ? Money.new(original_tax_cents, original_tax_currency || Money.default_currency)  : nil},
      :converter => Proc.new { |value| value.respond_to?(:to_money) ? value.to_money : raise(ArgumentError, "Can't convert #{value.class} to Money") }
    end
  end

  def has_money_helpers *attrs
     attrs.each do |attr|
       attr_as_string = "#{attr}_as_string"

       class_eval <<-"END"
       def #{attr_as_string}
         @#{attr_as_string} || #{attr}.try(&:with_currency)
       end
       def #{attr_as_string}= (value)
         value.upcase!
         @#{attr_as_string} = value
         if value.match MONEY_VALIDATION_REGEXP
           self.#{attr} = value.to_money
         end
       end
       END
       validates_format_of attr_as_string, :with => MONEY_VALIDATION_REGEXP, :allow_blank => true, :message =>  "некорректное значение: '#{attr_as_string}', валютные значения следует вводить в таком формате: '10 USD'"
     end
  end
end

# encoding: utf-8
module MoneyColumns
  extend ActiveSupport::Concern
  MONEY_VALIDATION_REGEXP = / \d+ (?:.\d{2})? \s* (?:USD|EUR|RUB) $/x

  def has_money_columns *columns
    money_columns = columns.every.to_sym
    money_columns.each do |column|
    composed_of column,
      :class_name => 'Money',
      :mapping => [%w(original_tax_cents cents), %w(original_tax_currency currency_as_string)],
      :constructor => Proc.new { |original_tax_cents, original_tax_currency| original_tax_cents ? Money.new(original_tax_cents, original_tax_currency || Money.default_currency)  : nil},
      :converter => Proc.new { |value| value.respond_to?(:to_money) ? value.to_money : raise(ArgumentError, "Can't convert #{value.class} to Money") }
    end
  end

  def has_money_helpers *attrs
    attr_helpers = attrs.map{ |name|(name.to_s+'_as_string').to_sym }
    [attrs, attr_helpers].transpose.each do |attr, attr_helper|
      define_method "#{attr_helper}" do
        instance_variable_get"@#{attr_helper}" || method(attr).call.try(&:with_currency)
      end
      define_method "#{attr_helper}=" do |value|
        instance_variable_set "@#{attr_helper}", value
        if value.match MONEY_VALIDATION_REGEXP
          method((attr.to_s+'=').to_sym).call(value.to_money)
          save
        end
      end
    end
    validates_each attr_helpers, :allow_blank => true do |model, attr, fx|
      model.errors.add(attr, ", некорректное значение: '#{fx}', валютные значения следует вводить в таком формате: '10 USD") unless fx.match(MONEY_VALIDATION_REGEXP)
    end
  end
end

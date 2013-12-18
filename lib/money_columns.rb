# encoding: utf-8
module MoneyColumns
  extend ActiveSupport::Concern
  # FIXME вернуть валидацию на два знака после запятой
  MONEY_VALIDATION_REGEXP = /^ \s* (?:-\s*)? \d+ (?:\.\d+)? \s* (?:USD|EUR|RUB) \s* $/x

  MONEY_CONSTRUCTOR = Proc.new do |cents, currency|
    # возможно, проверять не надо, если composed_of allow_nil: true
    cents ? Money.new(cents, currency || Money.default_currency) : nil
  end

  MONEY_CONVERTER = Proc.new do |value|
    case
    when value.is_a?(Hash)
      value["amount"] && value["amount"].to_money(value["currency"])
    when value.respond_to?(:to_money)
      value.to_money
    else
      raise(ArgumentError, "Can't convert #{value.class} to Money")
    end
  end

  def has_money_columns *columns
    money_columns = columns.every.to_sym
    money_columns.each do |column|
      composed_of column,
        class_name: 'Money',
        mapping: {"#{column}_cents" => 'cents', "#{column}_currency" => 'currency_as_string'},
        constructor: MONEY_CONSTRUCTOR,
        converter: MONEY_CONVERTER
    end
  end

  # TODO setter, как минимум, можно снести
  def has_money_helpers *attrs
     attrs.each do |attr|
       attr_as_string = "#{attr}_as_string"

       class_eval <<-"END", __FILE__, __LINE__ + 1
       def #{attr_as_string}
         @#{attr_as_string} || (#{attr} && #{attr}.is_a?(Money) ? #{attr}.with_currency : nil)
       end
       def #{attr_as_string}= (value)
         value.upcase!
         @#{attr_as_string} = value
         if value.match MONEY_VALIDATION_REGEXP
           self.#{attr} = value.to_money
         end
       end
       def customized_#{attr}
         #{attr} && #{attr}.is_a?(Money) ? #{attr}.with_currency : 'Unknown'
       end
       END
       validates_format_of attr_as_string, :with => MONEY_VALIDATION_REGEXP, :allow_blank => true, :message =>  "некорректное значение: '#{attr_as_string}', валютные значения следует вводить в таком формате: '10 USD'"
     end
  end
end

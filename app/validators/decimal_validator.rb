# encoding: utf-8

# TODO тестик бы
class DecimalValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    attr_before_type_cast = record.send("#{attribute}_before_type_cast")
    if attr_before_type_cast.is_a?(String)
      if attr_before_type_cast[',']
        record.errors[attribute] << ' - копейки отделяются точкой, а не запятой.'
      end
      if attr_before_type_cast.strip[' ']
        record.errors[attribute] << ' - пробелы между цифрами.'
      end
    end
  end
end

# encoding: utf-8

# TODO тестик бы
class NotChangedValidator < ActiveModel::EachValidator
  # validates :foo, not_changed: true, :if => proc { somecondition }
  def validate_each(record, attribute, value)
    if record.send("#{attribute}_changed?")
      original_value = record.send("#{attribute}_was")
      record.errors[attribute] << "изменение запрещено. Закрепленное значение: '#{original_value}'"
    end
  end
end

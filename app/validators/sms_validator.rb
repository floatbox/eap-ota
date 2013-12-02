# encoding: utf-8

require 'active_model'

class SMSValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    # длина смс с кириллицей - 70 символов
    # без - 160 символов
    return false if value.blank?
    max_length = value =~ /\P{ASCII}/ ? 70 : 160
    unless value.length <= max_length
      record.errors.add(attribute, I18n.t('activerecord.validations.sms_message'))
    end
    true
  end
end


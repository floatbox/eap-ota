class Deck::SMS < ActiveRecord::Base
  set_table_name :deck_sms
  attr_accessible :status, :message, :address

  validate :status, presence: true
  validate :address, presence: true
  # TODO добавить смс-валидатор
  validate :message#, sms: true
end

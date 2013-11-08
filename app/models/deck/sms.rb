# encoding: utf-8

class Deck::SMS < ActiveRecord::Base
  set_table_name :deck_sms
  attr_accessible :status, :message, :address

  validate :status, presence: true
  validate :address, presence: true
  validate :message, presence: true, allow_blank: false, sms: true
end

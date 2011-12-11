# encoding: utf-8
class Payment < ActiveRecord::Base
  belongs_to :order
  attr_accessor :custom_fields

  CHARGES = ['PaytureCharge', 'CashCharge']
  REFUNDS = ['PaytureRefund', 'CashRefund']

  scope :charges, where(:type => CHARGES)
  scope :refunds, where(:type => REFUNDS)

  def self.[] id
    find id
  end

  # для админки
  def to_label
    "#{ref} #{name_in_card} #{'%.2f' % price} р. #{payment_status}"
  end

  def self.systems
    ['payture', 'cash']
  end

end


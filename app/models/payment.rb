# encoding: utf-8
class Payment < ActiveRecord::Base

  has_paper_trail

  belongs_to :order
  attr_accessor :custom_fields

  CHARGES = ['PaytureCharge', 'CashCharge']
  REFUNDS = ['PaytureRefund', 'CashRefund']

  scope :charges, where(:type => CHARGES)
  scope :refunds, where(:type => REFUNDS)

  PAYTURE = ['PaytureCharge', 'PaytureRefund']
  CASH =    ['CashCharge', 'CashRefund']

  scope :payture, where(:type => PAYTURE)
  scope :cash, where(:type => CASH)
  def self.types; PAYTURE + CASH end

  def self.statuses; %W[ pending threeds blocked charged rejected voided ] end

  def self.[] id
    find id
  end

  # для админки
  def to_label
    "#{type} ##{id} #{'%.2f' % price} р. #{payment_status}"
  end

  def self.systems
    ['payture', 'cash']
  end

  # TODO override in subclasses
  def payment_state_raw
    "--"
  end

  def error_explanation
  end

  def show_link
    title = "#{type} ##{id}"
    "<a href='/admin/payments/show/#{id}'>#{title}</a>".html_safe
  end

  def control_links
    ''
  end

end


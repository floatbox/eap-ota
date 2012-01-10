# encoding: utf-8
class Payment < ActiveRecord::Base

  has_paper_trail
  extend Commission::Columns

  after_initialize :set_initial_status
  # порядок важен!
  before_save :set_defaults
  before_save :recalculate_earnings

  belongs_to :order
  attr_accessor :custom_fields
  has_commission_columns :commission

  CHARGES = ['PaytureCharge', 'CashCharge']
  REFUNDS = ['PaytureRefund', 'CashRefund']

  scope :charges, where(:type => CHARGES)
  scope :refunds, where(:type => REFUNDS)

  PAYTURE = ['PaytureCharge', 'PaytureRefund']
  CASH =    ['CashCharge', 'CashRefund']

  scope :payture, where(:type => PAYTURE)
  scope :cash, where(:type => CASH)
  def self.types; PAYTURE + CASH end

  def self.statuses; %W[ pending threeds blocked charged rejected canceled ] end

  # Payment.blocked, payment.blocked?.., and so on.
  statuses.each do |status|
    scope status, where(:status => status)

    eval <<-"end_of_method"
      def #{status}?
        status == '#{status}'
      end
    end_of_method
  end

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

  # вызывается и после считывания из базы
  def set_initial_status
    self.status ||= 'blocked'
  end

  # распределение дохода
  def set_defaults
    # to be overriden in subclasses
  end

  def income_payment_gateways
    0
  end

  def recalculate_earnings
    self.earnings = price - income_payment_gateways
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

  # оверрайдить в субклассах-рефандах
  def charge_link
  end


  def control_links
    ''
  end

end


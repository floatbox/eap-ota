# encoding: utf-8
class Payment < ActiveRecord::Base

  include TypusPayment

  # дефолтные издержки на транзакцию
  def self.commission
    @commission ||= Commission::Formula.new(Conf.payment.commission)
  end

  def self.select_class(gateway, kind=:charge)
    case [gateway, kind]
    when [:payture, :charge]; PaytureCharge
    when [:payture, :refund]; PaytureRefund
    when [:payu,    :charge]; PayuCharge
    when [:payu,    :refund]; PayuRefund
    when [:cash,    :charge]; CashCharge
    when [:cash,    :refund]; CashRefund
    else raise ArgumentError, "no subclass for gateway: #{gateway.inspect}, kind: #{kind.inspect}"
    end
  end

  # зачатки payment strategy
  # сейчас создает только кредитнокарточковые платежи
  def self.select_and_create(args)
    gateway = args.delete(:gateway).presence || Conf.payment.card_processing.to_sym

    # можно false
    return unless gateway

    select_class(gateway).create(args)
  end

  # эвристика для поиска 3дсовых платежей в разных системах
  def self.find_3ds_by_backref!(params)
    payment =
      if params[:MD].present?
        PaytureCharge.find_by_threeds_key(params[:MD])
      elsif params[:REFNO].present?
        PayuCharge.find_by_their_ref(params[:REFNO])
      end

    unless payment
      raise ArgumentError, "strange params for confirm_3ds: #{params.inspect}"
    end

    payment
  end

  has_paper_trail
  extend Commission::Columns

  after_initialize :set_initial_status
  # порядок важен!
  before_save :set_defaults
  before_save :recalculate_earnings
  after_save :update_incomes_in_order

  belongs_to :order
  delegate :pnr_number, :to => :order
  attr_accessor :custom_fields
  has_commission_columns :commission

  # для вьюшек тайпуса. оверрайдим в субклассах.
  belongs_to :charge, :class_name => 'Payment', :foreign_key => 'charge_id'
  has_many :refunds, :class_name => 'Payment', :foreign_key => 'charge_id'
  has_and_belongs_to_many :imports

  # не секьюрити ради, а read_only тайпуса для
  attr_protected :type

  validates :price, decimal: true
  validate :check_pnr_number

  CHARGES = ['PayuCharge', 'PaytureCharge', 'CashCharge']
  REFUNDS = ['PayuRefund', 'PaytureRefund', 'CashRefund']

  scope :charges, where(:type => CHARGES)
  scope :refunds, where(:type => REFUNDS)

  PAYU =    ['PayuCharge', 'PayuRefund']
  PAYTURE = ['PaytureCharge', 'PaytureRefund']
  CASH =    ['CashCharge', 'CashRefund']
  CARDS =   PAYU + PAYTURE

  scope :payu, where(:type => PAYU)
  scope :payture, where(:type => PAYTURE)
  scope :cash, where(:type => CASH)
  scope :cards, where(:type => CARDS)
  def self.types
    (PAYU + PAYTURE + CASH).map {|type| [I18n.t(type), type] }
  end

  # состояния, для оверрайда в подкласах и чтоб кнопки работали
  def can_block?;       false end
  def can_confirm_3ds?; false end
  def can_cancel?;      false end
  def can_charge?;      false end
  def can_sync_status?; false end

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

  STATUS_GROUPS = {
    :secured => %W[ blocked charged processing_charge ],
    :not_secured => %W[ pending threeds rejected unblocked canceled ],
    :processing => %W[ processing_block processing_threeds processing_charge processing_cancel ]
  }

  # Payment.secured, payment.secured?, Payment.not_secured, payment.not_secured?.., and so on.
  STATUS_GROUPS.each do |status_group, statuses|
    scope status_group, where(:status => statuses)

    eval <<-"end_of_method"
      def #{status_group}?
        STATUS_GROUPS[:#{status_group}].include? status
      end
    end_of_method
  end

  scope :processing_too_long, lambda { processing.where("updated_at < ?", 5.minutes.ago) }

  # понимает маски для LIKE, но работает быстрее, когда не маска
  scope :by_pan, lambda {|pan| (pan['%'] || pan['_']) ? where("pan like ?", pan) : where(pan: pan) }

  def self.[] id
    find id
  end

  def self.systems
    ['payture', 'cash']
  end

  def check_pnr_number
    return true unless @pnr_number
    errors.add(:pnr_number, 'Должен быть указан PNR существующего заказа') if Order.where(:pnr_number => @pnr_number).count != 1
  end

  def pnr_number=(number)
    number.upcase!
    @pnr_number = number
    if number != pnr_number && (Order.where(:pnr_number => number).count == 1)
      self.order = Order.find_by_pnr_number(number)
    end
  end

  # вызывается и после считывания из базы
  def set_initial_status
    self.status ||= 'blocked'
  end

  def update_incomes_in_order
    if order
      order.secured_payments.reload
      order.update_incomes
    end
  end

  def is_charge?
    type.in? Payment::CHARGES
  end

  # распределение дохода
  def set_defaults
    # to be overriden in subclasses
  end

  def income_payment_gateways
    0
  end

  def recalculate_earnings
    self.earnings = (price - income_payment_gateways).round(2)
  end

end


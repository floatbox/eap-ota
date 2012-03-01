# encoding: utf-8
class Order < ActiveRecord::Base

  include CopyAttrs
  include Pricing::Order
  include IncomeDistribution

  # FIXME сделать модуль или фикс для typus, этим оверрайдам место в typus/application.yml
  def self.model_fields
    super.merge(
      :price_payment_commission => :decimal,
      :price_tax_extra => :decimal,
      :income => :decimal,
      :income_suppliers => :decimal,
      :income_payment_gateways => :decimal
    )
  end

  # new - дефолтное значение без смысла
  # not blocked - ожидание 3ds, неприход наличных, убивается шедулером
  # unblocked - разблокирование денег на карте
  # blocked - блокирование денег на карте
  # charged - списание денег с карты или приход наличных
  # pending - ожидание оплаты наличныии или курьером
  def self.payment_statuses
    ['not blocked', 'blocked', 'charged', 'new', 'pending']
  end

  def self.ticket_statuses
    [ 'booked', 'canceled', 'ticketed']
  end

  def self.sources
    [ 'amadeus', 'sirena', 'other']
  end

  def self.payment_types
    ['card', 'delivery', 'cash', 'invoice']
  end

  def self.pricing_methods
    [['Обычный', ''], ['Корпоративный (эквайринг 0%)', 'corporate_0001']]
  end

  def self.commission_ticketing_methods
    [['Авиацентр (Сирена, MOWR2233B)', 'aviacenter'], ['Прямой договор (MOWR228FA)', 'direct']]
  end

  # фейковый текст для маршрут-квитанций. может быть, вынести в хелпер?
  PAID_BY = {'card' => 'Invoice', 'delivery' => 'Cash', 'cash' => 'Cash', 'invoice' => 'Invoice'}

  attr_writer :itinerary_receipt_view

  extend Commission::Columns
  has_commission_columns :commission_agent, :commission_subagent, :commission_consolidator, :commission_blanks, :commission_discount, :commission_our_markup
  has_percentage_only_commissions :commission_consolidator, :commission_discount, :commission_our_markup

  def self.[] number
    find_by_pnr_number number
  end

  def make_payable_by_card
    update_attributes(:payment_type => 'card', :payment_status => 'not blocked', :offline_booking => true) if payment_status == 'pending'
  end

  has_paper_trail

  has_many :payments

  # не_рефанды
  def last_payment
    payments.charges.last
  end

  has_many :tickets
  has_many :order_comments
  has_many :notifications
  validates_uniqueness_of :pnr_number, :if => :'pnr_number.present?'

  before_validation :capitalize_pnr
  before_save :calculate_price_with_payment_commission, :if => lambda { price_with_payment_commission.blank? || price_with_payment_commission.zero? || !fix_price? }
  before_create :generate_code, :set_payment_status, :set_email_status
  after_save :create_notification

  def create_notification
    if !self.offline_booking && self.email_status == ''
      case self.source
      when 'amadeus'
        if self.ticket_status == 'booked' && (self.payment_status == 'blocked' || self.payment_status == 'pending')
          self.notifications.new.create_pnr
        end
      when 'sirena'
        if self.ticket_status == 'ticketed'
          self.notifications.new.create_pnr
        end
      end
    end
  end

  def queued_email!
    update_attribute(:email_status, 'queued') if self.email_status == ''
  end

  # FIXME сломается на ruby1.9
  def capitalize_pnr
    self.pnr_number = pnr_number.to_s.mb_chars.strip.upcase
  end

  scope :unticketed, where(:payment_status => 'blocked', :ticket_status => 'booked')
  scope :ticketed, where(:payment_status => ['blocked', 'charged'], :ticket_status => 'ticketed')

  scope :stale, lambda {
    where(:payment_status => 'not blocked', :ticket_status => 'booked', :offline_booking => false, :source => 'amadeus')\
      .where("created_at < ?", 30.minutes.ago)
  }

  def contact
    "#{email} #{phone}"
  end

  #флаг для админки
  def urgent
    if  payment_status == 'blocked' && ticket_status == 'booked' &&
        ((last_tkt_date && last_tkt_date == Date.today) ||
         (departure_date && departure_date < Date.today + 3.days)
        )
      '!'
    else
      '&nbsp;'.html_safe
    end
  end

  def tickets_count
    tickets.count
  end

  def order_id
    last_payment.try(:ref)
  end

  def need_attention
    1 if price_difference != 0
  end

  def price_refund
    tickets.where(:kind => 'refund').every.price_refund.sum
  end

  def generate_code
    self.code = ShortUrl.random_hash
  end

  # по этой штуке во маршрут-квитанции определяется, "бронирование" это или уже "билет"
  # FIXME избавиться от глупостей типа "пишем что это билет, хотя это еще бронирование"
  # FIXME добавить проверки на обилеченность, может быть? для ручных бронек
  def show_as_ticketed?
    ticket_status == 'ticketed' || payment_type == 'card'
  end

  def paid?
    payment_type == 'card'
  end

  def paid_by
    PAID_BY[payment_type]
  end

  def order_form= order_form
    recommendation = order_form.recommendation
    order_form.set_vat_attrs
    copy_attrs order_form, self,
      :email,
      :phone,
      :pnr_number,
      :full_info,
      :sirena_lead_pass,
      :last_tkt_date,
      :payment_type,
      :delivery,
      :last_pay_time,
      :partner,
      :marker,
      :show_vat,
      :vat_included

    copy_attrs recommendation, self,
      :source,
      :blank_count,
      :price_tax,
      :price_fare,
      :price_with_payment_commission

    self.route = recommendation.variants[0].flights.every.destination.join('; ')
    self.cabins = recommendation.cabins.join(',')
    self.departure_date = recommendation.variants[0].flights[0].dept_date
    # FIXME вынести рассчет доставки отсюда
    if order_form.payment_type != 'card'
      self.cash_payment_markup = recommendation.price_payment + (order_form.payment_type == 'delivery' ? 350 : 0)
    end
    if recommendation.commission
      copy_attrs recommendation.commission, self, {:prefix => :commission},
        :carrier,
        :ticketing_method,
        :agent,
        :subagent,
        :consolidator,
        :blanks,
        :discount,
        :our_markup,
        :agent_comments,
        :subagent_comments

      copy_attrs recommendation, self,
        :price_agent,
        :price_subagent,
        :price_consolidator,
        :price_blanks,
        :price_discount,
        :price_our_markup
    end
    self.ticket_status = 'booked'
    self.name_in_card = order_form.card.name
    self.pan = order_form.card.pan
  end

  def raw # FIXME тоже в стратегию?
    Strategy.select(:order => self).raw_pnr
  rescue => e
    e.message
  end

  def load_tickets
    @tickets_are_loading = true
    ticket_hashes = Strategy.select(:order => self).get_tickets
    ticket_hashes.each do |th|
      if th[:office_id].blank? || Ticket.office_ids.include?(th[:office_id])
        t = tickets.ensure_exists(th[:number])
        th[:vat_included] = vat_included unless t.vat_included
        th.delete(:ticketed_date) if t.ticketed_date # Видимо нужно было для случаев, когда авиакомпания переписывала билет, но точно не помню
        t.update_attributes th
      end
    end

    #Необходимо, тк t.update_attributes глючит при создании билетов (не обновляет self.tickets)
    tickets.reload
    @tickets_are_loading = false

  end

  def sold_tickets
    tickets.where(:status => 'ticketed').reject {|t| t.children.where(:processed => true).present?}
  end

  def update_prices_from_tickets # FIXME перенести в strategy
    # не обновляем цены при загрузке билетов, если там вдруг нет комиссий
    return if old_booking || @tickets_are_loading
    price_total_old = self.price_total

    self.price_fare = sold_tickets.every.price_fare.sum
    self.price_tax = sold_tickets.every.price_tax.sum

    self.price_consolidator = sold_tickets.every.price_consolidator.sum
    self.price_agent = sold_tickets.every.price_agent.sum
    self.price_subagent = sold_tickets.every.price_subagent.sum
    self.price_blanks = sold_tickets.every.price_blanks.sum
    self.price_discount = sold_tickets.every.price_discount.sum
    self.price_our_markup = sold_tickets.every.price_our_markup.sum

    self.price_difference = price_total - price_total_old if price_difference == 0
    save
  end

  # считывание offline брони из GDS
  ######################################
  extend CastingAccessors
  attr_accessor :needs_update_from_gds
  cast_to_boolean :needs_update_from_gds
  validate :needs_update_from_gds_filter, :if => :needs_update_from_gds

  def needs_update_from_gds_filter
    update_from_gds
  # rescue => e
  #  errors.add(:needs_update_from_gds, e.message)
  end

  def update_from_gds
    assign_attributes Strategy.select(:order => self).booking_attributes
  end

  # пересчет тарифов и такс
  ######################################
  validate :needs_recalculation_filter, :if => :needs_recalculation

  def needs_recalculation
    ticket_status != 'ticketed'
  end

  def needs_recalculation_filter
    # из PricingMethods::Order
    recalculation
  rescue => e
    errors.add(:recalculation_alert, e.message)
  end

  def recalculation_alert
    if needs_recalculation
      "Суммы такс, сборов и скидок будут пересчитаны."
    else
      "Суммы такс, сборов и скидок НЕ будут пересчитаны, если заказ в состоянии 'ticketed'. Редактируйте каждый билет отдельно."
    end + ' ' +
      if fix_price
        "Итоговая стоимость не изменится при перерасчете, если закреплена 'Итоговая цена'"
      else
        "Итоговая стоимость будет пересчитана, если ее не закрепить или если поле пустое."
      end
  end

  def created_date
    created_at.to_date
  end

  delegate :payture_state, :charged_on, :payture_amount,
    :to => :last_payment, :allow_nil => true

  def confirm_3ds pa_res, md
    if result = last_payment.confirm_3ds!(pa_res, md)
      money_blocked!
    end
    result
  end

  def charge!
    res = last_payment.charge!
    update_attribute(:payment_status, 'charged') if res
    res
  end

  def unblock!
    res = last_payment.cancel!
    update_attribute(:payment_status, 'unblocked') if res
    res
  end

  def block_money card, order_form = nil, ip = nil
    custom_fields = PaymentCustomFields.new(:ip => ip, :order_form => order_form, :order => self)
    payment = PaytureCharge.create(:price => price_with_payment_commission, :card => card, :custom_fields => custom_fields, :order => self)
    response = payment.block!
    money_blocked! if response.success?
    response
  end

  def recalculated_price_with_payment_commission
    if tickets.present?
      sold_tickets.every.price_with_payment_commission.sum
    else
      price_with_payment_commission
    end
  end

  def money_blocked!
    update_attribute(:fix_price, true)
    update_attribute(:payment_status, 'blocked')
    self.fix_price = true
  end

  def money_received!
    if payment_status == 'pending'
      update_attribute(:fix_price, true)
      self.fix_price = true
      update_attribute(:payment_status, 'charged')
      create_cash_payment
    end
  end

  def create_cash_payment
    CashCharge.create(:price => price_with_payment_commission, :commission => acquiring_commission, :order => self)
  end

  def no_money_received!
    update_attribute(:payment_status, 'not blocked') if payment_status == 'pending'
  end

  def ticket!
    update_attributes(:ticket_status =>'ticketed', :ticketed_date => Date.today)

    load_tickets
  end

  def reload_tickets
    load_tickets
    update_prices_from_tickets
  end

  def cancel!
    update_attribute(:ticket_status, 'canceled')
  end

  def email_ready!
    update_attribute(:email_status, '')
  end

# class methods

  # FIXME надо какой-то логгинг
  def self.cancel_stale!
    stale.each do |order|
      begin
        puts "Automatic cancel of pnr #{order.pnr_number}"
        Strategy.select(:order => order).cancel
      rescue
        puts "error: #{$!}"
      end
    end
  end

  def set_payment_status
    self.payment_status = (payment_type == 'card') ? 'not blocked' : 'pending'
  end

  def set_email_status
    self.email_status = (source == 'amadeus') ? 'not ready' : ''
  end

  # для админки
  def to_label
    "#{source} #{pnr_number}"
  end

  def self.api_stats_hash orders
    orders.map do |order|
      {
      :id => order.id.to_s,
      :marker => order.marker,
      :price => order.price_with_payment_commission,
      :income => '%.2f' % order.income,
      :created_at => order.created_at,
      :route => order.route
      }
    end
  end
end


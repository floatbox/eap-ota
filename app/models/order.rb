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
  has_commission_columns :commission_agent, :commission_subagent, :commission_consolidator, :commission_blanks, :commission_discount
  has_percentage_only_commissions :commission_consolidator, :commission_discount

  def self.[] number
    find_by_pnr_number number
  end

  def make_payable_by_card
    update_attributes(:payment_type => 'card', :payment_status => 'not blocked', :offline_booking => true) if payment_status == 'pending'
  end

  has_paper_trail

  has_many :payments
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
          self.notifications.create
        end
      when 'sirena'
        if self.ticket_status == 'ticketed'
          self.notifications.create
        end
      end
    end
  end



  # FIXME сломается на ruby1.9
  def capitalize_pnr
    self.pnr_number = pnr_number.mb_chars.strip.upcase
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
    payments.last ? payments.last.ref : ''
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
      :partner

    copy_attrs recommendation, self,
      :source,
      :blank_count,
      :price_our_markup,
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
        :agent_comments,
        :subagent_comments

      copy_attrs recommendation, self,
        :price_agent,
        :price_subagent,
        :price_our_markup,
        :price_consolidator,
        :price_blanks,
        :price_discount
    end
    self.ticket_status = 'booked'
    self.name_in_card = order_form.card.name
    self.last_digits_in_card = order_form.card.number4
  end

  def raw # FIXME тоже в стратегию?
    Strategy.new(:order => self).raw_pnr
  rescue => e
    e.message
  end

  def payment_state_raw
    if payment_type == 'card'
       "#{payture_state} #{payture_amount}"
    else
      "не использовалась"
    end
  rescue => e
    "ошибка получения состояния: #{e.message}"
  end

  def load_tickets
    if source == 'amadeus'
      pnr_resp = tst_resp = nil
      Amadeus.booking do |amadeus|
        pnr_resp = amadeus.pnr_retrieve(:number => pnr_number)
        tst_resp = amadeus.ticket_display_tst(:number => pnr_number)
        amadeus.pnr_ignore
      end
      prices = tst_resp.prices_with_refs
      pnr_resp.tickets.deep_merge(tst_resp.prices_with_refs).each do |k, ticket_hash|
        if ticket_hash[:number]
          t = tickets.ensure_exists(ticket_hash[:number])
          ticket_hash.delete(:ticketed_date) if t.ticketed_date
          if Ticket.office_ids.include? ticket_hash[:office_id]
            t.update_attributes(ticket_hash.merge({
              :processed => true,
              :source => 'amadeus',
              :pnr_number => pnr_number,
              :commission_subagent => commission_subagent.to_s
            })
            )
          end
        end
      end
      #Необходимо, тк t.update_attributes глючит при создании билетов (не обновляет self.tickets)
      tickets.reload
      update_attribute(:departure_date, pnr_resp.flights.first.dept_date) if pnr_resp.flights.present?
    elsif source == 'sirena'
      order_resp = Sirena::Service.new.order(pnr_number, sirena_lead_pass)
      ticket_dates = Sirena::Service.new.pnr_status(pnr_number).tickets_with_dates
      order_resp.ticket_hashes.each do |t|
        ticket = tickets.ensure_exists(t[:number])
        t['ticketed_date'] = ticket_dates[t[:number]] if ticket_dates[t[:number]]
        ticket.update_attributes(t.merge({:processed => true}))
      end
      tickets.reload
      update_attribute(:departure_date, order_resp.flights.first.dept_date)
    end

  end

  def update_prices_from_tickets # FIXME перенести в strategy
    # не обновляем цены при загрузке билетов, если там вдруг нет комиссий
    return if old_booking
    price_total_old = self.price_total
    sold_tickets = tickets.where(:status => 'ticketed')

    self.price_fare = sold_tickets.sum(:price_fare)
    self.price_tax = sold_tickets.sum(:price_tax)

    self.price_consolidator = sold_tickets.sum(:price_consolidator)
    self.price_agent = sold_tickets.sum(:price_agent)
    self.price_subagent = sold_tickets.sum(:price_subagent)
    self.price_blanks = sold_tickets.sum(:price_blanks)
    self.price_discount = sold_tickets.sum(:price_discount)

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

  # злая временная копипаста из load_from_tickets
  def update_from_gds
    if source == 'amadeus'
      pnr_resp = tst_resp = nil
      Amadeus.booking do |amadeus|
        pnr_resp = amadeus.pnr_retrieve(:number => pnr_number)
        tst_resp = amadeus.ticket_display_tst(:number => pnr_number)
        amadeus.pnr_ignore
      end
      self.departure_date = pnr_resp.flights.first.dept_date
      if tst_resp.success?
        self.price_fare = tst_resp.total_fare
        self.price_tax = tst_resp.total_tax
        self.commission_carrier = tst_resp.validating_carrier_code
        self.blank_count = tst_resp.blank_count
      end

    elsif source == 'sirena'
      order_resp = Sirena::Service.new.order(pnr_number, sirena_lead_pass)
      self.departure_date = order_resp.flights.first.dept_date
      hash = pricing_hash_for_sirena(order_resp)
      pricing_resp = Sirena::Service.new.pricing_variant(hash)
      recommendation_resp = pricing_resp.recommendations.first #по замыслу всегда 1 рек-я
      self.price_fare = recommendation_resp.total_fare
      self.price_tax = recommendation_resp.total_tax

    end

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

  def payture_state
    payments.last ? payments.last.payture_state : ''
  end

  def charge_date
    (payments.last && payments.last.charged_at) ? payments.last.charged_at.to_date : nil
  end

  def created_date
    created_at.to_date
  end

  def charge_time
    (payments.last && payments.last.charged_at) ? payments.last.charged_at.strftime('%H:%m') : nil
  end

  def payture_amount
    payments.last ?  payments.last.payture_amount : nil
  end

  def confirm_3ds pa_res, md
    payments.last.confirm_3ds pa_res, md
  end

  def charge!
    res = payments.last.charge!
    update_attribute(:payment_status, 'charged') if res
    res
  end

  def unblock!
    res = payments.last.unblock!
    update_attribute(:payment_status, 'unblocked') if res
    res
  end

  def block_money card, order_form = nil, ip = nil
    custom_fields = PaymentCustomFields.new(:ip => ip)
    if order_form
      custom_fields.order_form = order_form
    else
      custom_fields.order = self
    end
    payment = Payment.create(:price => price_with_payment_commission, :card => card, :order => self, :custom_fields => custom_fields, :system => 'payture')
    payment.payture_block
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
    Payment.create(:price => price_with_payment_commission, :order => self, :system => 'cash')
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

  def resend_email!
    update_attribute(:email_status, '')
  end

  def queued_email!
    update_attribute(:email_status, 'queued')
  end


# class methods

  # FIXME надо какой-то логгинг
  def self.cancel_stale!
    stale.each do |order|
      puts "Automatic cancel of pnr #{order.pnr_number}"
      Strategy.new(:order => order).cancel
    end
  end

  def set_payment_status
    self.payment_status = (payment_type == 'card') ? 'not blocked' : 'pending'
  end
  
  def set_email_status
    self.email_status = (source == 'amadeus') ? 'not ready' : ''
  end

  # надо указать текущую сумму. чтобы нечаянно не рефанднуть дважды
  def refund(original_amount, refund_amount)
    ref = {:order_id => payments.last.ref}
    reported_amount = Payture.new.state(ref).amount
    if original_amount != reported_amount
      raise "it should have been #{original_amount} charged, got #{reported_amount} instead"
    end
    Payture.new.refund(refund_amount, ref)
  end

  # для админки
  def to_label
    "#{source} #{pnr_number}"
  end

  def pricing_hash_for_sirena(order)

    variants = Variant.new(
      :segments => order.flights.collect do |flight|

      Segment.new( :flights => [flight])
      end )

    recommendation =  Recommendation.new(
      :source => 'sirena',
      :booking_classes => order.booking_classes,
      :variants => [variants]
    )

    passengers = order.passengers
    hash = {:recommendation => recommendation, :given_passengers => passengers}
  end



end


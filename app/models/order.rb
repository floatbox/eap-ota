# encoding: utf-8
class Order < ActiveRecord::Base

  include CopyAttrs
  include Pricing::Order

  scope :MOWR228FA, lambda { by_office_id 'MOWR228FA' }
  scope :MOWR2233B, lambda { by_office_id 'MOWR2233B' }
  scope :MOWR221F9, lambda { by_office_id 'MOWR221F9' }
  scope :MOWR2219U, lambda { by_office_id 'MOWR2219U' }
  scope :FLL1S212V, lambda { by_office_id 'FLL1S212V' }


  def self.by_office_id office_id
    joins(:tickets).where('tickets.office_id' => office_id).uniq
  end

  # FIXME сделать модуль или фикс для typus, этим оверрайдам место в typus/application.yml
  def self.model_fields
    super.merge(
      :price_payment_commission => :decimal,
      :price_tax_extra => :decimal,
      :income => :decimal,
      :income_suppliers => :decimal,
      :income_payment_gateways => :decimal,
      :expected_income => :decimal
    )
  end

  # new - дефолтное значение без смысла
  # not blocked - ожидание 3ds, неприход наличных, убивается шедулером
  # unblocked - разблокирование денег на карте
  # blocked - блокирование денег на карте
  # charged - списание денег с карты или приход наличных
  # pending - ожидание оплаты наличныии или курьером
  def self.payment_statuses
    ['not blocked', 'blocked', 'charged', 'new', 'pending', 'unblocked']
  end

  def self.ticket_statuses
    [ 'booked', 'canceled', 'ticketed', 'processing_ticket', 'error_ticket']
  end

  def self.ticket_office_ids
    Ticket.uniq.pluck(:office_id).compact.sort
  end

  def self.partners
    Partner.pluck :token
  end

  def show_vat
    sold_tickets.present? && sold_tickets.all?(&:show_vat) && sold_tickets.every.office_id.uniq != ['FLL1S212V']
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
    [['Авиацентр (Сирена, MOWR2233B)', 'aviacenter'], ['Прямой договор (MOWR228FA)', 'direct'], ['Downtown Travel (FLL1S212V)', 'downtown']]
  end

  # фейковый текст для маршрут-квитанций. может быть, вынести в хелпер?
  PAID_BY = {'card' => 'Invoice', 'delivery' => 'Cash', 'cash' => 'Cash', 'invoice' => 'Invoice'}

  attr_writer :itinerary_receipt_view

  extend Commission::Columns
  has_commission_columns :commission_agent, :commission_subagent, :commission_consolidator, :commission_blanks, :commission_discount, :commission_our_markup
  has_percentage_only_commissions :commission_consolidator

  def self.[] number
    find_by_pnr_number number
  end

  def make_payable_by_card
    update_attributes(:payment_type => 'card', :payment_status => 'not blocked', :offline_booking => true) if payment_status == 'pending'
  end

  has_paper_trail

  has_many :payments
  has_many :secured_payments, :conditions => ['status IN (?)', %W[ blocked charged processing_charge ]], :class_name => 'Payment'

  # не_рефанды
  def last_payment
    payments.charges.last
  end

  has_many :tickets
  has_many :order_comments
  has_many :notifications
  has_one :promo_code
  validates_uniqueness_of :pnr_number, :if => :'pnr_number.present?'

  before_validation :capitalize_pnr
  before_save :calculate_price_with_payment_commission, :if => lambda { price_with_payment_commission.blank? || price_with_payment_commission.zero? || !fix_price? }
  before_create :generate_code, :set_payment_status, :set_email_status
  after_save :create_order_notice

  def create_order_notice
    if !offline_booking && email_status == ''
      if ticket_status == 'booked' && (payment_status == 'blocked' || payment_status == 'pending')
        self.notifications.new.create_delayed_notice
      end
    end
  end

  def create_ticket_notice
    if email_status != 'queued' && email_status != 'ticket_sent' && email_status != 'manual'
      self.notifications.new.create_delayed_notice 2
    end
  end

  def baggage_array
    return [] unless sold_tickets.all?{|t| t.baggage_info.present?}
    sold_tickets.map do |t|
      t.baggage_info.to_s.split.map{|code| BaggageLimit.deserialize(code)}
    end.transpose
  end

  def email_ready!
    update_email_status
  end

  def queued_email!
    update_email_status 'queued'
  end

  def email_manual!
    update_email_status 'manual'
  end

  def update_email_status status = ''
    update_attribute(:email_status, status)
  end

  # FIXME сломается на ruby1.9
  def capitalize_pnr
    self.pnr_number = pnr_number.to_s.mb_chars.strip.upcase
  end

  scope :unticketed, where(:payment_status => 'blocked', :ticket_status => 'booked')
  scope :processing_ticket, where(:ticket_status => 'processing_ticket')
  scope :error_ticket, where(:ticket_status => 'error_ticket')
  scope :ticketed, where(:payment_status => ['blocked', 'charged'], :ticket_status => 'ticketed')
  scope :ticket_not_sent, where("email_status != 'ticket_sent' AND ticket_status = 'ticketed'")
  scope :sent_manual, where(:email_status => 'manual')


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
      '<b>~ ! ~</b><br/>'.html_safe + ticket_time_decorated
    else
      ticket_time_decorated
    end
  end

  def ticket_time_decorated
#    if payment_status == 'blocked' && ticket_status == 'booked' && created_at > Date.yesterday + 20.5.hours
    if payment_status == 'blocked' && (ticket_status.in? 'booked', 'processing_ticket', 'error_ticket')
      now = DateTime.now
      date_to_ticket = ticket_datetime
      time_diff = ((date_to_ticket - now)/60).to_i
      if time_diff > 0
        time_diff = 180 if time_diff > 180
        time_diff_param = (time_diff.to_f*127/180).to_i
        rcolor = (255 - time_diff_param)
        gcolor = (time_diff_param)
        bcolor = 127
        color = "#%02X%02X%02X" % [rcolor, gcolor, gcolor]
      else
        color = "#ff0000; font-weight: bold";
      end
      "<span style='color:#{color};'>#{date_to_ticket.strftime('%H:%M')}</span><br/><abbr class='timeago' title='#{date_to_ticket}'>#{date_to_ticket}</abbr>".html_safe
    else
      '&nbsp;'.html_safe
    end
  end

  def ticket_datetime
    time = created_at.strftime('%H%M')
    case
      when time < '0600';  created_at.midnight + 11.hours
      when time < '0800';  created_at + 4.hours
      when time < '2030';  created_at + 3.hours
      else                 created_at.tomorrow.midnight + 11.hours
    end
  end

  def tickets_count
    tickets.count
  end

  def sold_tickets_numbers
    sold_tickets.every.number_with_code.join('; ')
  end

  def tickets_office_ids_array
    tickets.collect{|t| t.office_id}.uniq
  end

  def tickets_office_ids
    tickets_office_ids_array.join('; ')
  end

  def order_id
    last_payment.try(:ref)
  end

  def need_attention
    1 if price_difference != 0
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

  def send_notice_as
    if ticket_status == 'ticketed'
      'ticket'
    elsif payment_type == 'card'
      'order'
    else
      'booking'
    end
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
      :partner,
      :marker

    copy_attrs recommendation, self,
      :source,
      :blank_count,
      :price_tax,
      :price_fare,
      :price_with_payment_commission

    self.route = recommendation.journey.flights.every.destination.join('; ')
    self.cabins = recommendation.cabins.join(',')
    self.departure_date = recommendation.journey.flights[0].dept_date
    # FIXME вынести рассчет доставки отсюда
    if order_form.payment_type != 'card'
      self.cash_payment_markup = recommendation.price_payment + (order_form.payment_type == 'delivery' ? 400 : 0)
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

  def strategy
    Strategy.select(:order => self)
  end

  def raw # FIXME тоже в стратегию?
    strategy.raw_pnr
  rescue => e
    e.message
  end

  def load_tickets(check_count = false)
    ticket_hashes = strategy.get_tickets
    if !check_count || !blank_count || ticket_hashes.length >= blank_count
      @tickets_are_loading = true
      ticket_hashes.each do |th|
        if (th[:office_id].blank? || Ticket.office_ids.include?(th[:office_id])) &&
            !tickets.find_by_number(th[:number])
          tickets.create(th)
        end
      end

      #Необходимо, тк t.update_attributes глючит при создании билетов (не обновляет self.tickets)
      tickets.reload
      @tickets_are_loading = false
      true
    else
      false
    end
  end

  # Нужен для Маршрут квитанции (список билетов, подсчет цен)
  def sold_tickets
    tickets.where(:status => 'ticketed')
  end

  # возвращает boolean
  def update_prices_from_tickets
    tickets.reload
    # не обновляем цены при загрузке билетов, если там вдруг нет комиссий
    return if old_booking || @tickets_are_loading || sold_tickets.blank? || sold_tickets.any?{|t| t.office_id == 'FLL1S212V'}
    price_total_old = self.price_total

    self.price_fare = sold_tickets.sum(:price_fare)
    self.price_tax = sold_tickets.sum(:price_tax)

    self.price_consolidator = sold_tickets.sum(:price_consolidator)
    self.price_agent = sold_tickets.sum(:price_agent)
    self.price_subagent = sold_tickets.sum(:price_subagent)
    self.price_blanks = sold_tickets.sum(:price_blanks)
    self.price_discount = sold_tickets.sum(:price_discount)
    self.price_our_markup = sold_tickets.sum(:price_our_markup)

    self.price_difference = price_total - price_total_old if price_difference == 0
    save
  end

  # использовать для сравнения с TST
  def prices
    [price_fare, price_tax]
  end

  # считывание offline брони из GDS
  ######################################
  extend CastingAccessors
  attr_accessor :needs_update_from_gds
  cast_to_boolean :needs_update_from_gds
  validate :needs_update_from_gds_filter, :if => :needs_update_from_gds

  def needs_update_from_gds_filter
    # молча не считываю, если операторы забыли ввести PNR или если это доплата
    update_from_gds if pnr_number.present?
  # rescue => e
  #  errors.add(:needs_update_from_gds, e.message)
  end

  def update_from_gds
    assign_attributes strategy.booking_attributes
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

  delegate :charged_on, :to => :last_payment, :allow_nil => true

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
    if tickets.present? && sold_tickets.every.office_id.uniq != ['FLL1S212V']
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

  # возвращает boolean
  def ticket!
    return false unless ticket_status.in? 'booked', 'processing_ticket', 'error_ticket'
    return false unless load_tickets(true)
    update_attributes(:ticket_status => 'ticketed', :ticketed_date => Date.today)
    update_prices_from_tickets
    create_ticket_notice
  end

  def reload_tickets
    load_tickets
    update_prices_from_tickets
  end

  def cancel!
    update_attribute(:ticket_status, 'canceled')
  end

# class methods

  # FIXME надо какой-то логгинг
  def self.cancel_stale!
    stale.each do |order|
      begin
        puts "Automatic cancel of pnr #{order.pnr_number}"
        order.strategy.cancel
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

  def payment_type_decorated
    if payment_type != 'card'
      "<span style='color:firebrick; font-weight:bold'>#{payment_type}</span>".html_safe
    else
      "<span style='color:gray;'>#{payment_type}</span>".html_safe
    end
  end

  def settled?
    !(ticket_status == 'canceled') && !has_refunds? && income > 0 && tickets.all?{|t| t.status == 'ticketed'}
  end

  def api_stats_hash
    settled = settled?
    hash_to_send = {
    :id => id.to_s,
    :marker => marker,
    :price => price_with_payment_commission,
    :income => '%.2f' % (settled ? income : '0'),
    :created_at => created_at,
    :route => route,
    :settled => settled && (payment_status == 'charged')
    }
    hash_to_send.delete(:income) if Partner[partner] && Partner[partner].hide_income
    hash_to_send
  end
end

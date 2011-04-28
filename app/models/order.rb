# encoding: utf-8
class Order < ActiveRecord::Base

  PAYMENT_STATUS = {'not blocked' => 'not blocked', 'blocked' => 'blocked', 'charged' => 'charged', 'new' => 'new', 'pending' => 'pending'}
  TICKET_STATUS = { 'ticketed' => 'ticketed', 'booked' => 'booked', 'canceled' => 'canceled'}
  SOURCE = { 'amadeus' => 'amadeus', 'sirena' => 'sirena' }

  has_many :payments
  has_many :tickets


  validates_presence_of :email, :if => (Proc.new{ |order| order.source != 'other' })
  validates_format_of :email, :with =>
    /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :message => "Некорректный email", :if => (Proc.new{ |order| order.source != 'other' })
  before_create :generate_code, :calculate_price_with_payment_commission

  scope :stale, lambda {
    where(:payment_status => 'not blocked', :ticket_status => 'booked')\
      .where("created_at < ?", 30.minutes.ago)
  }

  def order_id
    payments.last ? payments.last.ref : ''
  end

  def generate_code
    self.code = ShortUrl.random_hash
  end

  def calculate_price_with_payment_commission
    self.price_with_payment_commission = price_total + Payture.commission(price_total) if price_with_payment_commission == 0 || !price_with_payment_commission
  end

  def order_data= order_data
    recommendation = order_data.recommendation
    self.email = order_data.email
    self.phone = order_data.phone
    self.source = recommendation.source
    self.pnr_number = order_data.pnr_number
    self.price_total = recommendation.price_total
    self.price_fare = recommendation.price_fare
    self.price_with_payment_commission = recommendation.price_with_payment_commission
    self.full_info = order_data.full_info
    self.sirena_lead_pass = order_data.sirena_lead_pass
    self.last_tkt_date = order_data.last_tkt_date
    self.description = recommendation.variants[0].flights.every.destination.join('; ')
    self.payment_type = order_data.payment_type
    self.delivery = order_data.delivery
    self.last_pay_time = order_data.last_pay_time
    if order_data.payment_type != 'card'
      self.cash_payment_markup = recommendation.price_payment + (order_data.payment_type == 'delivery' ? 350 : 0)
    end
    if c = recommendation.commission
      self.commission_carrier = c.carrier
      self.commission_agent = c.agent
      self.commission_subagent = c.subagent
      self.commission_agent_comments = c.agent_comments
      self.commission_subagent_comments = c.subagent_comments
      self.price_share = recommendation.price_share
      self.price_our_markup = recommendation.price_our_markup
      self.price_consolidator_markup = recommendation.price_consolidator_markup
      self.price_tax_and_markup = recommendation.price_tax_and_markup
    end
    self.payment_status = (order_data.payment_type == 'card') ? 'not blocked' : 'pending'
    self.ticket_status = 'booked'
    self.name_in_card = order_data.card.name
    self.last_digits_in_card = order_data.card.number4
  end

  # вынести куда-нибудь
  def price_tax_and_markup_and_payment
    price_with_payment_commission - price_fare
  end

  # а это понадобилось сирене. тоже колонку завести?
  def price_tax
    price_total - price_consolidator_markup - price_our_markup - price_fare
  end

  def raw
    case source
    when 'amadeus'
      Amadeus::Service.pnr_raw(pnr_number)
    when 'sirena'
      Sirena::Service.pnr_history(:number => pnr_number).history
    end
  end

  def load_tickets
    if source == 'amadeus' && tickets.blank?
      pnr_resp = tst_resp = nil
      Amadeus.booking do |amadeus|
        pnr_resp = amadeus.pnr_retrieve(:number => pnr_number)
        tst_resp = amadeus.ticket_display_tst(:number => pnr_number)
        amadeus.pnr_ignore
      end
      prices = tst_resp.prices_with_refs
      pnr_resp.passengers.map do |passenger|
        ref = passenger.passenger_ref
        price_fare_ticket = prices.present? ? prices[ref][:price_fare] : 0
        price_tax_ticket = prices.present? ? prices[ref][:price_tax] : 0
        price_share_ticket = commission_subagent['%'] ? (price_fare_ticket * commission_subagent[0...-1].to_f / 100) : commission_subagent.to_f
        price_consolidator_markup_ticket = (price_share_ticket > 5) ? 0 : price_fare_ticket * 0.02
        Ticket.create(
          :order => self,
          :number => passenger.ticket.to_s,
          :commission_subagent => commission_subagent.to_s,
          :price_fare => price_fare_ticket,
          :price_tax => price_tax_ticket,
          :price_consolidator_markup => price_consolidator_markup_ticket,
          :price_share => price_share_ticket
        )
      end

      update_attribute(:ticket_numbers_as_text, pnr_resp.passengers.every.ticket.join(' '))
    end
  end

  def payture_state
    payments.last ? payments.last.payture_state : ''
  end

  def charge_date
    (payments.last && payments.last.charged_at) ? payments.last.charged_at.to_date : nil
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

  def block_money card
    payment = Payment.create(:price => price_with_payment_commission, :card => card, :order => self)
    payment.payture_block
  end

  def money_blocked!
    update_attribute(:payment_status, 'blocked')
    send_email
  end

  def money_received!
    update_attribute(:payment_status, 'charged') if payment_status == 'pending'
  end

  def no_money_received!
    update_attribute(:payment_status, 'not blocked') if payment_status == 'pending'
  end

  def ticket!
    update_attributes(:ticket_status =>'ticketed', :ticketed_date => Date.today)

    load_tickets
    send_receipt
  end

  def cancel!
    case source
    when 'amadeus'
      Amadeus.booking do |amadeus|
        amadeus.pnr_cancel(:number => pnr_number)
        update_attribute(:ticket_status, 'canceled')
      end
    when 'sirena'
      Sirena::Service.booking_cancel(pnr_number, sirena_lead_pass)
      update_attribute(:ticket_status, 'canceled')
    end
  end

  def send_email
    PnrMailer.notification(email, pnr_number).deliver if source == 'amadeus'
  end

  def send_receipt
    PnrMailer.sirena_receipt(email, pnr_number).deliver if source == 'sirena'
  end

# class methods

  # FIXME надо какой-то логгинг
  def self.cancel_stale!
    stale.each do |order|
      puts "Automatic cancel of pnr #{order.pnr_number}"
      order.cancel!
    end
  end

end


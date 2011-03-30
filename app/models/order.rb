# encoding: utf-8
class Order < ActiveRecord::Base

  PAYMENT_STATUS = {'not blocked' => 'not blocked', 'blocked' => 'blocked', 'charged' => 'charged', 'new' => 'new'}
  TICKET_STATUS = { 'ticketed' => 'ticketed', 'booked' => 'booked', 'canceled' => 'canceled'}
  SOURCE = { 'amadeus' => 'amadeus', 'sirena' => 'sirena' }

  has_many :payments


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
    self.payment_status = 'not blocked'
    self.ticket_status = 'booked'
    self.name_in_card = order_data.card.name
    self.last_digits_in_card = order_data.card.number4
  end

  def raw
    case source
    when 'amadeus'
      Amadeus::Service.pnr_raw(pnr_number)
    when 'sirena'
      Sirena::Service.pnr_history(:number => pnr_number).history
    end
  end

  def payture_state
    payments.last ? payments.last.payture_state : ''
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

  def ticket!
    update_attribute(:ticket_status, 'ticketed')
    send_receipt
  end

  def cancel!
    case source
    when 'amadeus'
      Amadeus.booking do |amadeus|
        amadeus.pnr_retrieve(:number => pnr_number)
        amadeus.pnr_cancel
        update_attribute(:ticket_status, 'canceled')
      end
    when 'sirena'
      Sirena::Service.booking_cancel(self)
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


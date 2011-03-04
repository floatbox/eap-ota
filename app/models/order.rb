# encoding: utf-8
class Order < ActiveRecord::Base

  PAYMENT_STATUS = {'not blocked' => 'not blocked', 'blocked' => 'blocked', 'charged' => 'charged'}
  TICKET_STATUS = { 'ticketed' => 'ticketed', 'booked' => 'booked', 'canceled' => 'canceled'}
  SOURCE = { 'amadeus' => 'amadeus', 'sirena' => 'sirena' }

  validates_presence_of :email#, :phone
  validates_format_of :email, :with =>
    /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :message => "Некорректный email"

  scope :stale, lambda {
    where(:payment_status => 'not blocked', :ticket_status => 'booked')\
      .where("created_at < ?", 30.minutes.ago)
  }

  def order_data= order_data
    recommendation = order_data.recommendation
    self.order_id = order_data.order_id
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
    Amadeus::Service.pnr_raw(pnr_number)
  end

  def payture_state
    Payture.new.state(:order_id => order_id).state
  end

  def payture_amount
    Payture.new.state(:order_id => order_id).amount
  end

  def confirm_3ds pa_res, md
    res = Payture.new.block_3ds(:order_id => self.order_id, :pa_res => pa_res)
    res.success?
  end

  def charge!
    res = Payture.new.charge(:order_id => self.order_id)
    update_attribute(:payment_status, 'charged') if res.success?
    res.success?
  end

  def unblock!
    res = Payture.new.unblock(self.price_with_payment_commission, :order_id => self.order_id)
    update_attribute(:payment_status, 'unblocked') if res.success?
    res.success?
  end

  def money_blocked!
    update_attribute(:payment_status, 'blocked')
    #Sirena::Adapter.approve_payment(self) if recommendation.source == 'sirena'
    send_email
  end

  def ticket!
    update_attribute(:ticket_status, 'ticketed')
  end

  def cancel!
    Amadeus.booking do |amadeus|
      amadeus.pnr_retrieve(:number => pnr_number)
      amadeus.pnr_cancel
      update_attribute(:ticket_status, 'canceled')
    end
  end

  def send_email
    PnrMailer.notification(email, pnr_number).deliver if email
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

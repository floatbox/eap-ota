# encoding: utf-8
class Order < ActiveRecord::Base

  PAYMENT_STATUS = {'not blocked' => 'not blocked', 'blocked' => 'blocked', 'charged' => 'charged'}
  TICKET_STATUS = { 'ticketed' => 'ticketed', 'booked' => 'booked', 'canceled' => 'canceled'}

  validates_presence_of :email#, :phone
  validates_format_of :email, :with =>
  /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :message => "Некорректный email"

  def order_data= order_data
    recommendation = order_data.recommendation
    self.order_id = order_data.order_id
    self.email = order_data.email
    self.phone = order_data.phone
    self.pnr_number = order_data.pnr_number
    self.price_total = recommendation.price_total
    self.price_with_payment_commission = recommendation.price_with_payment_commission
    self.full_info = order_data.full_info
    if c = recommendation.commission
      self.commission_carrier = c.carrier
      self.commission_agent = c.agent
      self.commission_subagent = c.subagent
      self.price_share = recommendation.price_share
      self.price_our_markup = recommendation.price_our_markup
      self.price_consolidator_markup = recommendation.price_consolidator_markup
      self.price_fare = recommendation.price_fare.to_i
      self.price_tax = recommendation.price_tax_and_markup.to_i
    end
    self.payment_status = 'not blocked'
    self.ticket_status = 'booked'
  end

  def raw
    Amadeus::Service.pnr_raw(pnr_number)
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
    send_email
  end

  def ticket!
    update_attribute(:ticket_status, 'ticketed')
  end

  def cancel!
    #использовать осторожно. Отменяет существующую бронь. видимо, при несработавшем 3ds использовать нельзя.
    Amadeus.booking do |amadeus|
      amadeus.pnr_retrieve(:number => pnr_number)
      amadeus.pnr_cancel
      update_attribute(:ticket_status, 'canceled')
    end
  end

  def send_email
    PnrMailer.notification(email, pnr_number).deliver if email
  end

end

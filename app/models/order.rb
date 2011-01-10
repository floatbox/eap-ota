class Order < ActiveRecord::Base

  PAYMENT_STATUS = { 'blocked' => 'blocked', 'charged' => 'charged'}
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
      self.price_markup = recommendation.price_markup
      self.price_fare = recommendation.price_fare.to_i
      self.price_tax = recommendation.price_tax_and_markup.to_i
    end
    self.payment_status = 'blocked'
    self.ticket_status = 'booked'
  end

  def raw
    Amadeus::Service.pnr_raw(pnr_number)
  end


  def charge
    res = Payture.new.charge(:order_id => self.order_id)
    update_attribute(:payment_status, 'charged') if res
    res
  end

  def unblock
    res = Payture.new.unblock(self.price_with_payment_commission, :order_id => self.order_id)
    update_attribute(:payment_status, 'unblocked') if res
    res
  end

  def ticket!
    update_attribute(:ticket_status, 'ticketed')
  end

  def cancel
    update_attribute(:ticket_status, 'canceled')
  end

end

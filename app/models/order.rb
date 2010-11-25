class Order < ActiveRecord::Base
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
    end
    self.payment_status = 'blocked'
  end

  def raw
    amadeus = Amadeus::Service.new(:book => true)
    res = amadeus.cmd("RT #{self.pnr_number}")
    amadeus.cmd('IG')
    res
  end


  def charge
    res = Payture.new.charge(:order_id => self.order_id)
    update_attribute(:payment_status, 'charged') if res["Success"] == "True"
    res
  end

  def unblock
    res = Payture.new.unblock(self.price_with_payment_commission, :order_id => self.order_id)
    update_attribute(:payment_status, 'unblocked') if res["Success"] == "True"
    res
  end

end

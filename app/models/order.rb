class Order < ActiveRecord::Base
  validates_presence_of :email#, :phone
  validates_format_of :email, :with => 
  /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :message => "Некорректный email"
  
  def order_data= order_data
    recommendation = order_data.recommendation
    self.email = order_data.email
    self.phone = order_data.phone
    self.pnr_number = order_data.pnr_number
    self.price_total = recommendation.price_total
    if c = recommendation.commission
      self.commission_carrier = c.carrier
      self.commission_agent = c.agent
      self.commission_subagent = c.subagent
      self.price_share = recommendation.price_share
      self.price_markup = recommendation.price_markup
    end
  end
  
end

=begin
имя пассажира
телефон
email пассажира
номер pnr
=end

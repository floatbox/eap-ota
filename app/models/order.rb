class Order < ActiveRecord::Base
  validates_presence_of :email#, :phone
  
  def recommendation= recommendation
    self.price_total = recommendation.price_total
    self.price_base = recommendation.price_base
    if c = recommendation.commission
      self.commission_carrier = c.carrier
      self.commission_agent = c.agent
      self.commission_subagent = c.subagent
      self.markup = c.markup(recommendation.price_base)
    end
  end
  
  
  def validate
    errors.add :email,           "Некорректный email"    if email && !(email =~ /^[a-zA-Z@\.]*$/)
    #errors.add :phone,       "Некорректный телефон"  if phone && !(phone =~ /^[0-9]*$/)
  end
end

=begin
имя пассажира
телефон
email пассажира
номер pnr
=end

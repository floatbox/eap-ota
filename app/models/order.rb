class Order < ActiveRecord::Base
  validates_presence_of :email#, :phone
  
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

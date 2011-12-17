# encoding: utf-8
class CashRefund < Payment

  belongs_to :charge, :class_name => 'CashCharge', :foreign_key => 'charge_id'

  before_create :set_ref

  before_validation :fix_price_sign

  def set_ref
    self.ref = charge.ref
    self.order_id = charge.order_id
  end

  def fix_price_sign
    if price && price > 0
      self.price = -price
    end
  end

  def charge!
    return unless status == 'new'
    self.charged_on = Date.today
    self.status = 'charged'
    self.save
    return true
  end

  def cancel!
    return if status == 'charged'
    self.status = 'canceled'
    self.save
  end

end

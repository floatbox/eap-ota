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
    return unless blocked?
    update_attributes :status => 'charged', :charged_on => Date.today
    return true
  end

  def cancel!
    return unless blocked?
    update_attributes :status => 'canceled'
    return true
  end

end

# encoding: utf-8
class CashRefund < Payment

  belongs_to :charge, :class_name => 'CashCharge', :foreign_key => 'charge_id'
  has_many :refunds, :through => :charge

  validates_presence_of :charge
  before_create :set_ref

  before_validation :fix_price_sign

  def set_ref
    self.order_id = charge.order_id
  end

  def fix_price_sign
    if price && price > 0
      self.price = "-#{price_before_type_cast.to_s.strip}"
    end
  end

  def can_block?; canceled? end
  def can_charge?; blocked? end
  def can_cancel?; blocked? end

  def charge!
    return unless can_charge?
    update_attributes :status => 'charged', :charged_on => Date.today
  end

  def cancel!
    return unless can_cancel?
    update_attributes :status => 'canceled'
  end

  def block!
    return unless can_block?
    update_attributes :status => 'blocked'
  end

end

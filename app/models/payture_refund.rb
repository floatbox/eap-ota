# encoding: utf-8
class PaytureRefund < Payment

  belongs_to :charge, :class_name => 'PaytureCharge', :foreign_key => 'charge_id'

  validates_presence_of :charge
  before_create :set_ref

  before_validation :fix_price_sign

  def set_ref
    self.ref = charge.ref
    self.order_id = charge.order_id
    self.name_in_card = charge.name_in_card
    self.pan = charge.pan
  end

  def fix_price_sign
    if price && price > 0
      self.price = -price
    end
  end

  def charge!
    return unless status == 'new'
    self.status = 'refunding'
    save
    res = Payture.new.refund( -price, :order_id => ref)
    if res.success?
      self.charged_on = Date.today
      self.status = 'charged'
      self.save
      return true
    else
      self.reject_reason = res.err_code
      self.save
    end
  rescue => e
    self.reject_reason = e.message
    save
    raise
  end

  def cancel!
    return if status == 'charged'
    self.status = 'canceled'
    self.save
  end

end

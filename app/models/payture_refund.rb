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
    return unless blocked?
    update_attributes :status => 'processing_refund'
    res = gateway.refund( -price, :order_id => ref)
    if res.success?
      update_attributes :status => 'charged', :charged_on => Date.today
      return true
    else
      update_attributes :status => 'processing_error', :reject_reason => res.err_code
    end
  rescue => e
    update_attributes :status => 'processing_error', :reject_reason => e
    raise
  end

  def cancel!
    return unless blocked?
    update_attributes :status => 'canceled'
  end

  def gateway
    Payture.new
  end

end

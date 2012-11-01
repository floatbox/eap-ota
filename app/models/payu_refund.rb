# encoding: utf-8
class PayuRefund < Payment

  belongs_to :charge, :class_name => 'PayuCharge', :foreign_key => 'charge_id'
  has_many :refunds, :through => :charge

  validates_presence_of :charge
  validates :price, not_changed: true, :if => :charged?

  before_create :set_ref

  before_validation :fix_price_sign

  def set_ref
    self.ref = charge.ref
    self.their_ref = charge.their_ref
    self.order_id = charge.order_id
    self.name_in_card = charge.name_in_card
    self.pan = charge.pan
  end

  def fix_price_sign
    if price && price > 0
      self.price = "-#{price_before_type_cast.to_s.strip}"
    end
  end

  def can_block?; canceled? end
  def can_cancel?; blocked? end
  def can_charge?; blocked? end

  def block!
    return unless can_block?
    update_attributes :status => 'blocked'
  end

  def charge!
    return unless can_charge?
    update_attributes :status => 'processing_charge'
    res = gateway.refund( -price, :their_ref => their_ref)
    if res.success?
      update_attributes :status => 'charged', :charged_on => Date.today
    else
      update_attributes :status => 'processing_charge', :error_code => res.err_code
    end
    res.success?
  rescue => e
    update_attributes :status => 'processing_charge', :error_code => e
    raise
  end

  def cancel!
    return unless can_cancel?
    update_attributes :status => 'canceled'
  end

  def gateway
    Payu.new
  end

  # для админки
  delegate :payment_status_raw, :external_gateway_link, :to => :charge

  def charge_link
    charge.show_link
  end

  def error_explanation
    [error_code, error_message].compact.join(': ')
  end

end

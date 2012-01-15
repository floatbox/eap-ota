# encoding: utf-8
class CashRefund < Payment

  #belongs_to :charge, :class_name => 'CashCharge', :foreign_key => 'charge_id'

  validates_presence_of :order
  before_create :set_ref

  before_validation :fix_price_sign

  def set_ref
    #self.ref = charge.ref
    #self.order_id = charge.order_id
  end

  def fix_price_sign
    if price && price > 0
      self.price = -price
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

  # для админки
  def self.refund_link(order_id)
    "<a href='/admin/cash_refunds/new?_popup=true&resource[order_id]=#{order_id}' class='iframe_with_page_reload'>Возврат наличными</a>".html_safe
  end
end

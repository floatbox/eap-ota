# encoding: utf-8
class CashCharge < Payment

  after_create :set_ref
  before_save :recalculate_earnings

  has_many :refunds, :class_name => 'CashRefund', :foreign_key => 'charge_id'

  def set_ref
    update_attribute(:ref, Conf.payment.order_id_prefix + id.to_s)
    update_attribute(:system, 'cash')
  end

  def charge!
    return unless blocked?
    update_attributes :status => 'charged', :charged_on => Date.today
  end

  def cancel!
    return unless blocked?
    update_attributes :status => 'canceled'
    return true
  end

  # распределение дохода
  def set_defaults
    self.commission = Conf.cash.commission if commission.blank?
  end

  # для админки
  def control_links
    refund_link
  end

  def refund_link
    "<a href='/admin/cash_refunds/new?_popup=true&resource[charge_id]=#{id}' class='iframe_with_page_reload'>Добавить возврат</a>".html_safe
  end
end

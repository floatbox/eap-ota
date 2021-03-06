# encoding: utf-8
class CashCharge < Payment

  include TypusCashCharge

  after_create :set_ref
  before_save :recalculate_earnings

  has_many :refunds, :class_name => 'CashRefund', :foreign_key => 'charge_id'

  def set_ref
    #update_attribute(:ref, Conf.payment.ref_prefix + id.to_s)
    #update_attribute(:system, 'cash')
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

  # распределение дохода
  def set_defaults
    self.commission = Conf.cash.commission if commission.blank?
  end

end

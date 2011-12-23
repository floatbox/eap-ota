# encoding: utf-8
class PaytureCharge < Payment

  # payment_status:
  # Authorized
  # Charged
  # New
  # PreAuthorized3DS
  # Refunded
  # Rejected
  # Voided

  after_create :set_ref
  before_save :recalculate_earnings

  attr_reader :card
  has_many :refunds, :class_name => 'PaytureRefund', :foreign_key => 'charge_id'

  def set_ref
    update_attribute(:ref, Conf.payment.order_id_prefix + id.to_s)
  end

  def card= card
    @card = card
    self.pan = card.pan
    self.name_in_card = card.name
  end

  def payture_block
    response = Payture.new.block(price, @card, :order_id => ref, :custom_fields => custom_fields)
    update_attribute(:reject_reason, response.err_code) if !response.success? && !response.threeds?
    update_attribute(:threeds_key, response.threeds_key) if response.threeds?
    response
  end

  def payture_state
    state = Payture.new.state(:order_id => ref).state
    update_attribute(:payment_status, state)
    state
  end

  def payture_amount
    Payture.new.state(:order_id => ref).amount
  end

  def confirm_3ds pa_res, md
    res = Payture.new.block_3ds(:order_id => ref, :pa_res => pa_res)
    update_attribute(:reject_reason, res.err_code) unless res.success?
    res.success?
  end

  def charge!
    res = Payture.new.charge(:order_id => ref)
    if res.success?
      self.charged_on = Date.today
      self.status = 'charged'
      save
    end
    res.success?
  end

  def unblock!
    res = Payture.new.unblock(price, :order_id => ref)
    res.success?
  end

  # распределение дохода
  def set_defaults
    self.commission = Conf.payture.commission if commission.blank?
  end

  def income_payment_gateways
    commission.call(price)
  end

  # для админки
  def control_links
    refund_link
  end

  def refund_link
    "<a href='/admin/payture_refunds/new?_popup=true&resource[charge_id]=#{id}' class='iframe_with_page_reload'>Добавить возврат</a>".html_safe
  end

  def error_explanation
    Payture::ERRORS_EXPLAINED[reject_reason] || reject_reason
  end

end

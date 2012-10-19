# encoding: utf-8
class PaytureCharge < Payment

  after_create :set_ref
  before_save :recalculate_earnings

  attr_reader :card
  has_many :refunds, :class_name => 'PaytureRefund', :foreign_key => 'charge_id'

  validates :price, not_changed: true, :if => :charged?

  # вызывается и после считывания из базы
  def set_initial_status
    self.status ||= 'pending'
  end

  def set_ref
    update_attributes(:ref => Conf.payture.ref_prefix + id.to_s)
  end

  def card= card
    @card = card
    self.pan = card.pan
    self.name_in_card = card.name
  end

  def can_block?; pending? end
  def can_confirm_3ds?; threeds? end
  def can_cancel?; blocked? end
  def can_charge?; blocked? end
  # FIXME ограничить processing_* статусами?
  def can_sync_status?; true end

  # TODO интеллектуальный retry при проблемах со связью
  def block!
    return unless can_block?
    raise ArgumentError, 'ref is not set yet' unless ref
    raise ArgumentError, 'price is 0' unless price && !price.zero?
    raise ArgumentError, 'specify card data, please' unless @card
    update_attributes :status => 'processing_block'
    response = gateway.block(price, @card, :our_ref => ref, :custom_fields => custom_fields)
    if response.threeds?
      update_attributes :status => 'threeds', :threeds_key => response.threeds_key
    elsif response.success?
      update_attributes :status => 'blocked'
    elsif response.error?
      update_attributes :status => 'rejected', :reject_reason => response.err_code
    else
      # FIXME оставляем status == 'processing_block' ???
    end
    response
  end

  def confirm_3ds! params
    return unless can_confirm_3ds?
    update_attributes :status => 'processing_threeds'
    res = gateway.block_3ds(:our_ref => ref, :PaRes => params[:PaRes])
    if res.success?
      update_attributes :status => 'blocked'
    else
      update_attributes :status => 'rejected', :reject_reason => res.err_code
    end
    res.success?
  end

  def charge!
    return unless can_charge?
    update_attributes :status => 'processing_charge'
    res = gateway.charge(:our_ref => ref)
    if res.success?
      update_attributes :status => 'charged', :charged_on => Date.today
    else
      update_attributes :status => 'blocked', :reject_reason => res.err_code
    end
    res.success?
  end

  def cancel!
    return unless can_cancel?
    update_attributes :status => 'processing_cancel'
    res = gateway.unblock(price, :our_ref => ref)
    if res.success?
      update_attributes :status => 'canceled'
    else
      update_attributes :status => 'blocked', :reject_reason => res.err_code
    end
    res.success?
  end

  def gateway
    Payture.new
  end

  def gateway_status
    response = gateway.status(:our_ref => ref)
    response.status || response.err_code
  end

  def gateway_amount
    gateway.status(:our_ref => ref).amount
  end

  STATUS_MAPPING = {
    'Authorized' => 'blocked',
    'Charged' => 'charged',
    'Refunded' => 'charged',
    'New' => 'pending',
    'PreAuthorized3DS' => 'threeds',
    'Rejected' => 'rejected',
    'Voided' => 'canceled',
    'ORDER_NOT_FOUND' => 'rejected'
  }

  def sync_status!
    return unless can_sync_status?
    status_code = gateway_status
    status = STATUS_MAPPING[status_code] or raise ArgumentError, "Unknown status reported by Payture: #{status_code.inspect}"
    update_attributes :status => status
  end

  # распределение дохода
  def set_defaults
    self.commission = Conf.payture.commission if commission.blank?
  end

  def income_payment_gateways
    commission.call(price)
  end

  # для админки
  def payment_status_raw
    response = gateway.status(:our_ref => ref)
    response.err_code || "#{response.status}: #{response.amount} (#{STATUS_MAPPING[response.status] || 'unknown'})"
  rescue
    $!.message
  end

  def control_links
    refund_link if charged?
  end

  def refund_link
    "<a href='/admin/payture_refunds/new?_popup=true&resource[charge_id]=#{id}' class='iframe_with_page_reload'>добавить возврат</a>".html_safe
  end

  def external_gateway_link
    url = "https://backend.payture.com/Payture/order.html?mid=55&pid=&id=#{ref}"
    "<a href='#{url}' target='_blank'>#{ref}</a>".html_safe
  end

  def error_explanation
    Payture::ERRORS_EXPLAINED[reject_reason] || reject_reason
  end

end

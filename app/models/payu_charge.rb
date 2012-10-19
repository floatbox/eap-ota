# encoding: utf-8
class PayuCharge < Payment

  after_create :set_ref
  before_save :recalculate_earnings

  attr_reader :card
  has_many :refunds, :class_name => 'PayuRefund', :foreign_key => 'charge_id'

  validates :price, not_changed: true, :if => :charged?

  # вызывается и после считывания из базы
  def set_initial_status
    self.status ||= 'pending'
  end

  def set_ref
    update_attributes(:ref => Conf.payu.ref_prefix + id.to_s)
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
  def can_sync_state?; true end

  def block!
    return unless can_block?
    # FIXME сделать это в валидации
    raise ArgumentError, 'ref is not set yet' unless ref
    raise ArgumentError, 'price is 0' unless price && !price.zero?
    raise ArgumentError, 'specify card data, please' unless @card
    raise ArgumentError, 'specify custom_fields, please' unless @custom_fields
    update_attributes :status => 'processing_block'
    response = gateway.block(price, @card, :our_ref => ref, :custom_fields => custom_fields)
    if response.threeds?
       update_attributes :status => 'threeds', :their_ref => response.their_ref
    elsif response.success?
       update_attributes :status => 'blocked', :their_ref => response.their_ref
    elsif response.error?
      update_attributes :status => 'rejected', :reject_reason => response.err_code
    else
      # FIXME оставляем status == 'processing_block' ???
    end
    return response
  end

  def confirm_3ds! params
    return unless can_confirm_3ds?
    # не делает запрос, просто парсит ответ от гейтвея
    res = gateway.parse_3ds(params)
    # FIXME что-то сделать более красивое? Оставляем в threeds состоянии
    raise "response HASH is wrong, security problem?" unless res.signed?

    if res.success?
      update_attributes :status => 'blocked', :their_ref => res.their_ref
    else
      update_attributes :status => 'rejected', :reject_reason => res.err_code
    end
    res.success?
  end

  def charge!
    return unless can_charge?
    update_attributes :status => 'processing_charge'
    res = gateway.charge(price, :their_ref => their_ref)
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
    res = gateway.unblock(price, :their_ref => their_ref)
    if res.success?
      update_attributes :status => 'canceled'
    else
      update_attributes :status => 'blocked', :reject_reason => res.err_code
    end
    res.success?
  end

  def gateway
    Payu.new
  end

  def gateway_state
    response = gateway.state(:our_ref => ref)
    response.state || response.err_code
  end

  STATUS_MAPPING = {
    'COMPLETE' => 'charged',
    'PAYMENT_AUTHORIZED' => 'blocked',
    'REFUND' => 'charged',
    'REVERSED' => 'canceled'
    # 'IN_PROGRESS' => 'processing_charge' ???
    # 'WAITING_PAYMENT' => 'processing_block' ???
  }

  def sync_state!
    return unless can_sync_state?
    state_code = gateway_state
    state = STATUS_MAPPING[state_code] or raise ArgumentError, "Unknown state reported by Payu: #{state_code.inspect}"
    update_attributes :status => state
  end

  # распределение дохода
  def set_defaults
    self.commission = Conf.payu.commission if commission.blank?
  end

  def income_payment_gateways
    commission.call(price)
  end

  # для админки
  def payment_status_raw
    response = gateway.status(:our_ref => ref)
    response.err_code || "#{response.status}: (#{STATUS_MAPPING[response.status] || 'unknown'})"
  rescue
    $!.message
  end

  def control_links
    refund_link if charged?
  end

  def refund_link
    "<a href='/admin/payu_refunds/new?_popup=true&resource[charge_id]=#{id}' class='iframe_with_page_reload'>добавить возврат</a>".html_safe
  end

  def external_gateway_link
    "not supported (id: #{their_ref})"
  end

  def error_explanation
    reject_reason
  end

end

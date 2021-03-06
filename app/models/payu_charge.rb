# encoding: utf-8
class PayuCharge < Payment

  include TypusPayuCharge

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
  def can_sync_status?; true end

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
      update_attributes :status => 'rejected', :error_code => response.err_code, :error_message => response.err_message
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
      update_attributes :status => 'rejected', :error_code => res.err_code, :error_message => res.err_message
    end
    res.success?
  end

  def charge!
    return unless can_charge?
    update_attributes :status => 'processing_charge'
    res = gateway.charge(:their_ref => their_ref, :payment_amount => price)
    if res.success?
      update_attributes :status => 'charged', :charged_on => Date.today
    else
      update_attributes :status => 'blocked', :error_code => res.err_code, :error_message => res.err_message
    end
    res.success?
  end

  def cancel!
    return unless can_cancel?
    update_attributes :status => 'processing_cancel'
    res = gateway.unblock(:their_ref => their_ref, :payment_amount => price)
    if res.success?
      update_attributes :status => 'canceled'
    else
      update_attributes :status => 'blocked', :error_code => res.err_code
    end
    res.success?
  end

  def gateway
    Payu.new
  end

  STATUS_MAPPING = {
    'NOT_FOUND' => 'rejected',
    'COMPLETE' => 'charged',
    'PAYMENT_AUTHORIZED' => 'blocked',
    'REFUND' => 'charged',
    'REVERSED' => 'canceled',
    'CARD_NOTAUTHORIZED' => 'rejected'
    # 'IN_PROGRESS' => 'processing_charge' ???
    # 'WAITING_PAYMENT' => 'processing_block' ???
  }

  def sync_status!
    return unless can_sync_status?
    response = gateway.status(:our_ref => ref)
    status_code = response.status
    their_ref = response.their_ref
    status = STATUS_MAPPING[status_code] or raise ArgumentError, "Unknown state reported by Payu: #{status_code.inspect}"
    update_attributes :status => status, :their_ref => their_ref
  end

  # распределение дохода
  def set_defaults
    self.commission = Conf.payu.commission if commission.blank?
  end

  def income_payment_gateways
    commission.apply(price)
  end

end

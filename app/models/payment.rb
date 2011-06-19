# encoding: utf-8
class Payment < ActiveRecord::Base
  belongs_to :order
  attr_reader :card

  # для админки
  def to_label
    "#{ref} #{name_in_card} #{'%.2f' % price} р. #{payment_status}"
  end

  def ref
    id_override || (Conf.payment.order_id_prefix + id.to_s)
  end

  def card= card
    @card = card
    self.last_digits_in_card = card.number4
    self.name_in_card = card.name
  end

  def payture_block
    response = Payture.new.block(price, @card, :order_id => ref)
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
    update_attribute(:charged_at, Time.now) if res.success?
    res.success?
  end

  def unblock!
    res = Payture.new.unblock(price, :order_id => ref)
    res.success?
  end

end


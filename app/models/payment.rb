class Payment < ActiveRecord::Base
  belongs_to :order


  def card= card
    @card = card
    self.last_digits_in_card = card.number4
    self.name_in_card = card.name
  end

  def payture_block
    response = Payture.new.block(price, @card, :order_id => id)
  end

  def payture_state
    state = Payture.new.state(:order_id => id).state
    update_attribute(:payment_status, state)
    state
  end

  def payture_amount
    Payture.new.state(:order_id => id).amount
  end

  def confirm_3ds pa_res, md
    res = Payture.new.block_3ds(:order_id => id, :pa_res => pa_res)
    res.success?
  end

  def charge!
    res = Payture.new.charge(:order_id => id)
    res.success?
  end

  def unblock!
    res = Payture.new.unblock(price, :order_id => id)
    res.success?
  end

end


class Payment < ActiveRecord::Base
  belongs_to :order
  attr_reader :card

  def payture_block
    response = Payture.new.block(price, @card, :order_id => id)
  end

  def payture_state
    Payture.new.state(:order_id => id).state
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


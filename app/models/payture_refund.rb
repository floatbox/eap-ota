class PaytureRefund < Payment

  belongs_to :charge, :class_name => 'PaytureCharge'

  before_create :set_ref

  def set_ref
    self.ref = charge.ref if charge
  end

  def refund!
    return unless status == 'New'
    res = Payture.new.refund(:order_id => ref)
    update_attribute(:charged_at, Time.now) if res.success?
    res.success?
  end

  # # надо указать текущую сумму. чтобы нечаянно не рефанднуть дважды
  # def refund(original_amount, refund_amount)
  #   ref = {:order_id => payments.last.ref}
  #   reported_amount = Payture.new.state(ref).amount
  #   if original_amount != reported_amount
  #     raise "it should have been #{original_amount} charged, got #{reported_amount} instead"
  #   end
  #   Payture.new.refund(refund_amount, ref)
  # end

end

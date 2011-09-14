class PaytureRefund < Payment

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

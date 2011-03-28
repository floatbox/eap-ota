module Sirena
  class Adapter
    def self.approve_payment(order)
      error_msg = nil
      pea_qu = Sirena::Service.payment_ext_auth(order, {:action=>"query"})

      if pea_qu.success? && pea_qu.cost
        pea_con = Sirena::Service.payment_ext_auth(order, {:action=>"confirm",
                                        :cost=>pea_qu.cost, :curr=>pea_qu.curr})
        if pea_con.success? && pea_con.common_status == 'ticket'
          order.ticket!
        else
          error_msg = pea_con.error
          Sirena::Service.payment_ext_auth(order, :action => 'cancel')
          # we can't simply cancel order if it is in query
          order.cancel!
        end
      else
        error_msg = pea_qu.error
        order.cancel!
      end
      error_msg
    end
  end
end
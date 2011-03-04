module Sirena
  class Adapter
    def self.approve_payment(order)
      pea_qu = Sirena::Service.payment_ext_auth(order, {:action=>"query"})
      
      pea_conf = Sirena::Service.payment_ext_auth(order, {:action=>"confirm",
                                        :cost=>pea_qu.cost, :curr=>pea_qu.curr})
    end
  end
end
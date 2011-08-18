# encoding: utf-8
module Admin::OrdersHelper
  def payture_backend_url order
    "https://backend.payture.com/Payture/order.html?id=#{order.order_id}&mid=55&pid=" if order.order_id
  end
end

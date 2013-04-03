# encoding: utf-8
module TypusCustomer

  extend ActiveSupport::Concern


  def orders_count_link
    "<a href='/admin/orders?customer_id=#{id}'>Заказов: #{orders.size}</a>".html_safe    
  end
  
end

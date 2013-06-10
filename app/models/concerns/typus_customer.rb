# encoding: utf-8
module TypusCustomer

  extend ActiveSupport::Concern

  def spyglass_link
    "<a href='/profile/spyglass/#{id}' target='_blank'>Шпионить</a>".html_safe
  end

  def orders_count_link
    "<a href='/admin/orders?customer_id=#{id}'>Заказов: #{orders.size}</a>".html_safe
  end
  
  def confirm_link
    "<a href='/profile/verification?confirmation_token=#{confirmation_token}'>#{confirmation_token}</a>".html_safe if !confirmation_token.blank?
  end
end

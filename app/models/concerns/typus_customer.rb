# encoding: utf-8
module TypusCustomer

  extend ActiveSupport::Concern

  def spyglass_link
    "<a href='/profile/spyglass/#{id}' target='_blank'>→<small>Шпионить</small></a>".html_safe
  end

  def orders_count_link
    "<a href='/admin/orders?customer_id=#{id}'>Заказов: #{orders.size}</a>".html_safe
  end

  def confirm_link
    "<a href='/#confirmation_token=#{confirmation_token}'>#{confirmation_token}</a>".html_safe if !confirmation_token.blank?
  end

  def admin_status
    return 'не зарегистрирован' if not_registred?
    return 'ждет подтверждения' if pending_confirmation?
    return 'подтвержден' if confirmed?
  end
end

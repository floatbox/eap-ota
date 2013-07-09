# encoding: utf-8
class AutoTicketStuff

  include KeyValueInit

  attr_accessor :recommendation
  attr_accessor :people
  attr_accessor :order

  def auto_ticket
    if reason = turndown_reason
      Rails.logger.info "No auto ticketing reason: #{reason}"
      false
    else
      true
    end
  rescue Exception => msg
    Rails.logger.error "Auto ticketing exception: #{msg}"
    nil
  end

  def turndown_reason
    Conf.site.auto_ticketing['enabled'] or return 'Автоматическое тикетирование выключено глобально'
    Conf.site.auto_ticketing['exclude_list'][order.commission_ticketing_method].to_a.exclude?(order.commission_carrier) or return 'Пара авиакомпания/офис выписки в списке исключений'
    order.payment_type == 'card' or return 'Заказ оплачивается не картой'
    order.ticket_status == 'booked' or return 'заказ не в статусе booked'
    !order.offline_booking or return 'offline заказ'
    recommendation.country_iatas.uniq.all?{|ci| Country[ci].continent != 'africa'} or return 'есть хотя бы один африканский город'
    people.all?{|p| ['RU', 'UA'].include?(p.nationality.alpha2)} or return 'есть пассажиры, не являющиеся гражданами РФ и Украины'
    !order.email['hotmail']  or return 'название почтового ящика содержит hotmail'
    !order.email['yahoo']  or return 'название почтового ящика содержит yahoo'
    (Order.where(email: order.email, payment_status: 'not blocked').where('created_at > ?', Time.now - 6.hours).count < 3) or return 'пользователь совершил две или больше неуспешных попытки заказа'#текущий заказ уже попадает в count
    #(Order.where(email: order.email, ticket_status: ['booked', 'ticketed', 'processing_ticket', 'error_ticket']).where('created_at > ?', Time.now - 6.hours).count < 2) or return 'пользователь совершил 1 успешный заказ ранее'#текущий заказ уже попадает в count
    people.map{|p| [p.first_name, p.last_name]}.uniq.count == people.count or return 'есть 2 пассажира с совпадающими именем и фамилией'
    nil
  end

  def create_auto_ticket_job
    Delayed::Job.enqueue AutoTicketJob.new(order_id: order.id), run_at: 30.minutes.from_now
  end
end

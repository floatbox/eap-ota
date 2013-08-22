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
    people.all?{|p| ['RU', 'UA', 'BY', 'MD'].include?(p.nationality.alpha2)} or return 'есть пассажиры, не являющиеся гражданами РФ, Украины, Белоруссии или Молдавии'
    !order.email['hotmail']  or return 'название почтового ящика содержит hotmail'
    !order.email['yahoo']  or return 'название почтового ящика содержит yahoo'
    (Order.where(email: order.email, payment_status: 'not blocked').where('created_at > ?', Time.now - 6.hours).count < 3) or return 'пользователь совершил две или больше неуспешных попытки заказа'#текущий заказ уже попадает в count
    no_dupe_orders? or return "dupe (#{@dupe_summary})"
    #!group_booking? or return "Скрытая группа (#{@other_order_pnrs.join(', ')})"
    people.map{|p| [p.first_name, p.last_name]}.uniq.count == people.count or return 'есть 2 пассажира с совпадающими именем и фамилией'
    nil
  end

  def create_auto_ticket_job
    Delayed::Job.enqueue AutoTicketJob.new(order_id: order.id), run_at: 30.minutes.from_now
  end

  def passenger_names(o)
    o.full_info.split("\n").map do |t|
      t.split('/')[0..1].join(' ')
    end
  end

  def no_dupe_orders?
    dupe_information = Hash.new([])
    passengers = passenger_names(order)
    order.stored_flights.each do |stored_flight|
      stored_flight.orders.where(ticket_status: ['booked', 'ticketed']).where('id != ?', order.id).each do |o|
        (passenger_names(o) & passengers).each do |p|
          dupe_information[p] += [o.pnr_number]
        end
      end
    end
    dupe_information.values.every.uniq!
    @dupe_summary = dupe_information.map{|k, v| "#{k}: #{v.join(', ')}"}.join('. ')
    return dupe_information.blank?
  end

  def group_booking?
    @other_order_pnrs = []
    order.stored_flights.any? do |stored_flight|
      orders = stored_flight.orders.where(ticket_status: ['booked', 'ticketed']).where('id != ?', order.id)#sum(:blank_count) > 8
      @other_order_pnrs += orders.every.pnr_number if orders.sum(:blank_count) + order.blank_count > 8
    end
    @other_order_pnrs.uniq!
    return @other_order_pnrs.present?
  end
end

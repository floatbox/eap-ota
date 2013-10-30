# encoding: utf-8
class AutoTicketStuff

  include KeyValueInit

  attr_accessor :recommendation
  attr_accessor :people
  attr_accessor :order
  BAD_DOMAINS = ['superrito.com', 'armyspy.com', 'cuvox.de', 'dayrep.com', 'einrot.com', 'fleckens.hu', 'gustr.com', 'jourrapide.com', 'rhyta.com', 'teleworm.us', 'writeme.com', 'europe.com', 'dropmail.me', 'alumni.com']
  SUSPICIOUS_DOMAINS = ['hotmail', 'yahoo', 'post.com', 'outlook.com', 'berlin.com']
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
    !used_card_with_different_name? or return "С большой вероятностью фрод. Выписка только после сравнения кода авторизации. Без кода категорически не выписывать! (card)"
    !looks_like_fraud? or return "С большой вероятностью фрод. Выписка только после сравнения кода авторизации. Без кода категорически не выписывать!"
    SUSPICIOUS_DOMAINS.each do |domain|
      !order.email.downcase[domain]  or return "название почтового ящика содержит #{domain}"
    end
    BAD_DOMAINS.each do |domain|
      !order.email.downcase[domain]  or return "С большой вероятностью фрод. Выписка только после сравнения кода авторизации. Без кода категорически не выписывать! (email)"
    end
    recommendation.country_iatas.uniq.all?{|ci| Country[ci].continent != 'africa'} or return 'есть хотя бы один африканский город'
    people.all?{|p| ['RU', 'UA', 'BY', 'MD'].include?(p.nationality.alpha2)} or return 'есть пассажиры, не являющиеся гражданами РФ, Украины, Белоруссии или Молдавии'
    (Order.where(email: order.email, payment_status: 'not blocked').where('created_at > ?', Time.now - 6.hours).count < 3) or return 'пользователь совершил две или больше неуспешных попытки заказа'#текущий заказ уже попадает в count
    no_dupe_orders? or return "dupe (#{@dupe_summary})"
    !group_booking? or return "Скрытая группа (#{@other_order_pnrs.join(', ')})"
    people.map{|p| [p.first_name, p.last_name]}.uniq.count == people.count or return 'есть 2 пассажира с совпадающими именем и фамилией'
    !people.any?(&:too_long_names?) or return 'слишком длинные имена пассажиров'
    !unaccompanied_child? or return "не сопровождаемый ребенок до 18 лет"
    nil
  end

  def create_auto_ticket_job
    Delayed::Job.enqueue AutoTicketJob.new(order_id: order.id),
      run_at: 15.minutes.from_now,
      queue: 'autoticketing'
  end

  def job_run_at
    return 15.minutes.from_now if order.commission_ticketing_method != 'aviacenter' ||
                                  Date.today.wday != 2 ||
                                  Time.now < Time.parse('20:30')
    tomorrow_rate = CBR.exchange_on(Date.tomorrow).exchange_with('2 USD'.to_money, "RUB").to_f.ceil / 2.0 #Курс амадеуса не завтра
    today_rate = Amadeus::Rate.exchange_on(Date.today).exchange_with('1 USD'.to_money, "RUB").to_f
    if tomorrow_rate > today_rate
      3.minutes.from_now
    elsif tomorrow_rate < today_rate
      Date.tomorrow + 1.minute
    else
      return 15.minutes.from_now
    end
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
    other_orders = order.stored_flights.first.orders.where(ticket_status: ['booked', 'ticketed']).where('id != ?', order.id).select do |o|
      order.stored_flights == o.stored_flights
    end
    if other_orders.every.blank_count.sum + order.blank_count > 8
      @other_order_pnrs = other_orders.every.pnr_number
    end
    return @other_order_pnrs.present?
  end

  def unaccompanied_child?
    people.all?{|p| p.birthday > (recommendation.dept_date - 18.years)} &&
      (([recommendation.validating_carrier_iata] +
        recommendation.marketing_carrier_iatas +
        recommendation.operating_carrier_iatas).uniq & ['KL', 'AF']).present?
  end

  def used_card_with_different_name?
    order.payment_type == 'card' && Order.where(pan: order.pan).where("name_in_card != ?", order.name_in_card).present?
  end

  def looks_like_fraud?
    (%W(+34 34 +36 36 +44 44 +49 49 +47 47 +42 42) & [order.phone[0..1], order.phone[0..2]]).present? ||
      (recommendation.airport_iatas & %W(TFS TFN)).present? ||
      %W(BRU RIX BCN).include?(recommendation.airport_iatas.first) ||
      (%W(BRU RIX BCN ).include?(recommendation.airport_iatas.last) &&
        recommendation.country_iatas.first != 'RU')
  end
end

# encoding: utf-8
class Order < ActiveRecord::Base

  include CopyAttrs

  PAYMENT_STATUS = ['not blocked', 'blocked', 'charged', 'new', 'pending']
  # new - дефолтное значение без смысла
  # not blocked - ожидание 3ds, неприход наличных, убивается шедулером
  # unblocked - разблокирование денег на карте
  # blocked - блокирование денег на карте
  # charged - списание денег с карты или приход наличных
  # pending - ожидание оплаты наличныии или курьером
  TICKET_STATUS = [ 'booked', 'canceled', 'ticketed']
  SOURCE = [ 'amadeus', 'sirena', 'other']
  PAYMENT_TYPE = ['card', 'delivery', 'cash']

  has_many :payments
  has_many :tickets
  validates_uniqueness_of :pnr_number, :scope => :source

  before_create :generate_code, :calculate_price_with_payment_commission, :set_payment_status

  scope :stale, lambda {
    where(:payment_status => 'not blocked', :ticket_status => 'booked', :offline_booking => false, :source => 'amadeus')\
      .where("created_at < ?", 30.minutes.ago)
  }

  scope :amadeus_email_queue, where(
    :email_status => '',
    :source => 'amadeus',
    :ticket_status => ['booked', 'ticketed'],
    :payment_status => ['blocked', 'charged'])\
    .where("email IS NOT NULL AND email != ''")

  scope :sirena_email_queue, where(
    :email_status => '',
    :source => 'sirena',
    :ticket_status => 'ticketed')\
    .where("email IS NOT NULL AND email != ''")


  def tickets_count
    ticket_numbers_as_text.to_s.split(/[, ]/).delete_if(&:blank?).size
  end

  def order_id
    payments.last ? payments.last.ref : ''
  end

  def need_attention
    1 if price_difference != 0
  end

  def price_total
    price_fare + price_tax + price_our_markup + price_consolidator_markup
  end

  def generate_code
    self.code = ShortUrl.random_hash
  end

  def calculate_price_with_payment_commission
    self.price_with_payment_commission = price_total + Payture.commission(price_total) if price_with_payment_commission == 0 || !price_with_payment_commission
  end

  # по этой штуке во маршрут-квитанции определяется, "бронирование" это или уже "билет"
  # FIXME избавиться от глупостей типа "пишем что это билет, хотя это еще бронирование"
  # FIXME добавить проверки на обилеченность, может быть? для ручных бронек
  def paid?
    payment_type == 'card'
  end

  def order_data= order_data
    recommendation = order_data.recommendation
    copy_attrs order_data, self,
      :email,
      :phone,
      :pnr_number,
      :full_info,
      :sirena_lead_pass,
      :last_tkt_date,
      :payment_type,
      :delivery,
      :last_pay_time

    copy_attrs recommendation, self,
      :source,
      :price_our_markup,
      :price_tax,
      :price_fare,
      :price_with_payment_commission

    self.route = recommendation.variants[0].flights.every.destination.join('; ')
    self.cabins = recommendation.cabins.join(',')
    if order_data.payment_type != 'card'
      self.cash_payment_markup = recommendation.price_payment + (order_data.payment_type == 'delivery' ? 350 : 0)
    end
    if recommendation.commission
      copy_attrs recommendation.commission, self, {:prefix => :commission},
        :carrier,
        :agent,
        :subagent,
        :agent_comments,
        :subagent_comments

      copy_attrs recommendation, self,
        :price_share,
        :price_our_markup,
        :price_consolidator_markup,
        :price_tax
    end
    self.ticket_status = 'booked'
    self.name_in_card = order_data.card.name
    self.last_digits_in_card = order_data.card.number4
  end

  # вынести куда-нибудь
  def price_tax_and_markup_and_payment
    price_with_payment_commission - price_fare
  end

  def price_tax_and_markup
    price_tax + price_consolidator_markup + price_our_markup
  end

  def raw
    case source
    when 'amadeus'
      Amadeus::Service.pnr_raw(pnr_number)
    when 'sirena'
      Sirena::Service.pnr_history(:number => pnr_number).history
    end
  end

  def load_tickets
    if source == 'amadeus'
      tickets.every.delete
      pnr_resp = tst_resp = nil
      Amadeus.booking do |amadeus|
        pnr_resp = amadeus.pnr_retrieve(:number => pnr_number)
        tst_resp = amadeus.ticket_display_tst(:number => pnr_number)
        amadeus.pnr_ignore
      end
      prices = tst_resp.prices_with_refs
      pnr_resp.passengers.map do |passenger|
        ref = passenger.passenger_ref
        if passenger.infant_or_child == 'i'
          price_fare_ticket = prices.present? ? prices[ref][:price_fare_infant].to_i : 0
          price_tax_ticket = prices.present? ? prices[ref][:price_tax_infant].to_i : 0
        else
          price_fare_ticket = prices.present? ? prices[ref][:price_fare].to_i : 0
          price_tax_ticket = prices.present? ? prices[ref][:price_tax].to_i : 0
        end
        price_share_ticket = commission_subagent['%'] ? (price_fare_ticket * commission_subagent[0...-1].to_f / 100) : commission_subagent.to_f
        price_consolidator_markup_ticket = (price_share_ticket > 5) ? 0 : price_fare_ticket * 0.02
        Ticket.create(
          :order => self,
          :number => passenger.ticket.to_s,
          :commission_subagent => commission_subagent.to_s,
          :price_fare => price_fare_ticket,
          :price_tax => price_tax_ticket,
          :price_consolidator_markup => price_consolidator_markup_ticket,
          :price_share => price_share_ticket,
          :cabins => cabins && cabins.gsub(/[MW]/, "Y").split(',').uniq.join(' + '),
          :route => route
        )
      end

      update_attribute(:ticket_numbers_as_text, pnr_resp.passengers.every.ticket.join(' '))
      update_attribute(:departure_date, pnr_resp.flights.first.dept_date)
    elsif source == 'sirena'
      tickets.every.delete
      order_resp = Sirena::Service.order(pnr_number, sirena_lead_pass)
      order_resp.tickets.each do |t|
        t.order = self
        t.save
      end
      update_attribute(:ticket_numbers_as_text, order_resp.passengers.every.ticket.join(' '))
      update_attribute(:departure_date, order_resp.flights.first.dept_date)
    end

  end

  def update_prices_from_tickets
    if source == 'amadeus'
      price_total_old = self.price_total
      self.price_fare = tickets.sum(:price_fare)
      self.price_consolidator_markup = tickets.sum(:price_consolidator_markup)
      self.price_share = tickets.sum(:price_share)

      self.price_tax = tickets.sum(:price_tax)
      self.price_difference = price_total - price_total_old if price_difference == 0
      save
    elsif source == 'sirena'
      self.price_fare = tickets.sum(:price_fare)
      self.price_tax = tickets.sum(:price_tax)
      save
    end
  end

  def payture_state
    payments.last ? payments.last.payture_state : ''
  end

  def charge_date
    (payments.last && payments.last.charged_at) ? payments.last.charged_at.to_date : nil
  end

  def created_date
    created_at.to_date
  end

  def charge_time
    (payments.last && payments.last.charged_at) ? payments.last.charged_at.strftime('%H:%m') : nil
  end

  def payture_amount
    payments.last ?  payments.last.payture_amount : nil
  end

  def confirm_3ds pa_res, md
    payments.last.confirm_3ds pa_res, md
  end

  def charge!
    res = payments.last.charge!
    update_attribute(:payment_status, 'charged') if res
    res
  end

  def unblock!
    res = payments.last.unblock!
    update_attribute(:payment_status, 'unblocked') if res
    res
  end

  def block_money card
    payment = Payment.create(:price => price_with_payment_commission, :card => card, :order => self)
    payment.payture_block
  end

  def money_blocked!
    update_attribute(:payment_status, 'blocked')
  end

  def money_received!
    update_attribute(:payment_status, 'charged') if payment_status == 'pending'
  end

  def no_money_received!
    update_attribute(:payment_status, 'not blocked') if payment_status == 'pending'
  end

  def ticket!
    update_attributes(:ticket_status =>'ticketed', :ticketed_date => Date.today)

    load_tickets
    update_prices_from_tickets
  end

  def reload_tickets
    load_tickets
    update_prices_from_tickets
  end

  def cancel!
    case source
    when 'amadeus'
      Amadeus.booking do |amadeus|
        amadeus.pnr_cancel(:number => pnr_number)
        update_attribute(:ticket_status, 'canceled')
      end
    when 'sirena'
      Sirena::Service.payment_ext_auth(:cancel, pnr_number, sirena_lead_pass)
      Sirena::Service.booking_cancel(pnr_number, sirena_lead_pass)
      update_attribute(:ticket_status, 'canceled')
    end
  end

  def send_email
    logger.info 'Order: sending email'
    PnrMailer.notification(email, pnr_number).deliver
    update_attribute(:email_status, 'sent')
  rescue
    update_attribute(:email_status, 'error')
    raise
  end

  def resend_email!
    update_attribute(:email_status, '')
  end

# class methods

  # FIXME надо какой-то логгинг
  def self.cancel_stale!
    stale.each do |order|
      puts "Automatic cancel of pnr #{order.pnr_number}"
      order.cancel!
    end
  end

  def self.process_queued_emails!
    counter = 0
    while (order_to_send = Order.sirena_email_queue.first || order_to_send = Order.amadeus_email_queue.first) && counter < 50
      order_to_send.send_email
      counter += 1
    end
    rescue
      HoptoadNotifier.notify($!) rescue Rails.logger.error("  can't notify hoptoad #{$!.class}: #{$!.message}")
  end

  def set_payment_status
    self.payment_status = (payment_type == 'card') ? 'not blocked' : 'pending'
  end

end


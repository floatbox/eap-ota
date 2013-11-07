# encoding: utf-8
require "rexml/document"
require 'net/http'
require 'uri'
require 'csv'

# народ, помечайте миграции в PaperTrail! однажды может здорово пригодиться.

module DataMigration

  # удаляет всех пользователей из deck_users и накатывает заново копиями из старого typus_users
  def self.migrate_admin_users
    Deck::User.delete_all
    Deck::User.connection.execute %(
      insert into deck_users (id, email, first_name, last_name, created_at, locked_at, roles)
        select id, email, first_name, last_name, created_at, if(status, null, updated_at), role from typus_users
    )
  end

  def self.get_cancelled_flights
    order_ids = StoredFlight.where('dept_date > ?', Date.today).every.tickets.flatten.every.order_id.uniq
    result = []
    Amadeus.ticketing do |amadeus|
      Order.where(ticket_status: 'ticketed', id: order_ids, source: 'amadeus').each do |order|
        if order.pnr_number.present? &&
           amadeus.pnr_retrieve(number: order.pnr_number).has_cancelled_flights?
          puts order.pnr_number
          result << order.pnr_number
        end
      end
    end
    result
  end

  def self.create_payments_csv
    PaperTrail.controller_info = {:done => 'Payu status sync'}
    d = Date.parse('2012-12-01')
    res = []
    payu = Payu.new
    while d < Date.today do
      res += payu.get_stats(d, d + 1.month)["data"].map{|r| {:status => r["Order status"], :ref => r['External Reference No'], :date => r['Order Finish Date']}}
      d += 1.month
    end
    res.uniq!
    CSV.open('payments.csv'  ,'w') do |csv|
      csv << %W[id charged_on status ref external_charged_on external_status external_status_raw]
      payment = nil
      res.each do |r|
        payment = if r[:status] == 'REFUND'
          PayuRefund.find_by_ref(r[:ref])
        else
          PayuCharge.find_by_ref(r[:ref])
        end
        external_status = PayuCharge::STATUS_MAPPING[r[:status]]
        begin
          external_charged_on = Time.parse(r[:date]).to_date
        rescue
          external_charged_on = nil
        end
        charged_on = payment && payment.charged_on
        status = payment && payment.status
        p_id = payment && payment.id
        if !payment || (external_status != status && !(r[:status] == 'PENDING' && ['threeds', 'rejected'].include?(payment.status))) || (external_status == 'charged' && external_charged_on != charged_on)
          csv <<  [p_id, charged_on, status, r[:ref],  external_charged_on, external_status, r[:status]]
        end
      end
    end
  end

  def self.sync_order_status_from_payments
    res = {}
    Order.where('created_at > ?', 7.month.ago).includes(:payments).map do |o|
     if o.calculated_payment_status && o.calculated_payment_status != o.payment_status
       res[o.id] = [o.calculated_payment_status, o.payment_status]
      end
    end
  end

  def self.sync_payments_with_payu
    PaperTrail.controller_info = {:done => 'Payu status sync'}
    d = Date.parse('2012-11-01')
    res = []
    payu = Payu.new
    while d < Date.today do
      res += payu.get_stats(d, d + 1.month)["data"].map{|r| {:status => r["Order status"], :ref => r['External Reference No'], :date => r['Order Finish Date'], :cr_date => r['Order Date'], :price => r['Total Price']}}
      d += 1.month
    end
    res.uniq!
    report = ''
    res.each do |r|
      payment = if r[:status] == 'REFUND'
        PayuRefund.find_by_ref_and_price(r[:ref], r[:price])
      else
        PayuCharge.find_by_ref(r[:ref])
      end
      external_status = PayuCharge::STATUS_MAPPING[r[:status]]
      begin
        external_charged_on = Time.parse(r[:date]).to_date
      rescue
        external_charged_on = nil
      end
      charged_on = payment && payment.charged_on
      status = payment && payment.status
      p_id = payment && payment.id
      if payment && status =~ /processing/ && external_status
        #report << "#{payment.id} #{status} -> #{external_status}\n"
        #payment.status = external_status
        if external_status == 'charged' && external_charged_on
          #report << "#{payment.id} #{charged_on} -> #{external_charged_on} (#{r[:cr_date]})\n"
          #payment.charged_on = external_charged_on
        end
        #payment.save
      elsif payment && r[:status] == 'REFUND' && external_charged_on && external_charged_on != charged_on
        #report << "refund #{payment.id} #{status} -> #{external_status}\n"
        #report << "refund #{payment.id} #{charged_on} -> #{external_charged_on} (#{r[:cr_date]})\n"
        #payment.charged_on = external_charged_on
        #payment.status = external_status
        #payment.save
      elsif payment && external_status != status && [external_status, status].include?('charged') && !(status == 'canceled' && external_status == 'charged') && external_charged_on < 15.days.ago.to_date
        report << "#{payment.id}(#{status} should be #{external_status})\n"
      end
    end
  end

  def self.ticket_original_prices(order)
    if order.sold_tickets.every.office_id.uniq.include?('FLL1S212V')
      ticket_hashes = order.strategy.get_tickets
      ticket_hashes.map do |th|
        stored_ticket = order.tickets.select{|t| t.code.to_s == th[:code].to_s && t.number.to_s[0..9] == th[:number].to_s}.first
        if stored_ticket && !stored_ticket.parent && th[:original_price_fare] && th[:original_price_total]
          {
            :id => stored_ticket.id,
            :original_price_fare => th[:original_price_fare].with_currency,
            :original_price_total => th[:original_price_total].with_currency
          }
        else
          nil
        end
      end
    else
      order.sold_tickets.map do |t| {
        :id => t.id,
        :original_price_fare => t.price_fare.to_money('RUB').with_currency,
        :original_price_tax => t.price_tax.to_money('RUB').with_currency
        }
      end
    end
  end


  def self.downtown_prices_migration
    Ticket.update_all "original_price_fare_cents = (price_fare * 100),
                       original_price_fare_currency = 'RUB',
                       original_price_tax_cents = (price_tax * 100),
                       original_price_tax_currency = 'RUB'"
    Ticket.update_all "original_price_penalty_cents = (price_penalty * 100),
                       original_price_penalty_currency = 'RUB'"
    Order.update_all('old_downtown_booking = 1', 'commission_ticketing_method = "downtown" and ticket_status = "ticketed"')
    Order.update_all('fee_scheme = "v3"', 'commission_ticketing_method = "downtown" and payment_type = "card"')
    load_ticket_prices_from_amadeus(Date.today - 1.day)
    #load_ticket_prices_from_csv #Предполагаем, что в tickets.csv лежат цены всех билетов
  end

  def self.load_ticket_prices_from_csv
    PaperTrail.controller_info = {:done => 'filling in prices in downtown tickets'}
    CSV.foreach('tickets.csv') do |id, fare, total|
      load_downtown_price(id, fare, total)
    end
  end

  def self.load_downtown_price(id, fare, total)
    t = Ticket.find(id)
    t.update_attributes(:original_price_total => total.to_money, :original_price_fare => fare.to_money)
    o = t.order
    if o.tickets.present? && o.tickets.all?{|t| t.kind == 'ticket' && t.status == 'ticketed' && t.original_price_fare_currency.present? && t.original_price_fare_currency != 'RUB' && t.corrected_price == 0}
      o.update_attributes(old_downtown_booking: false) if o.payment_type == "card"
      o.tickets.each do |t|
        t.corrected_price = t.calculated_price_with_payment_commission
        t.save
      end
      o.update_prices_from_tickets
    end
  end

  def self.load_ticket_prices_from_amadeus(date = Date.today)
    PaperTrail.controller_info = {:done => 'filling in prices in downtown tickets'}
    ticket_hashes = Order.by_office_id('FLL1S212V').where(:ticket_status => 'ticketed').where('orders.created_at >= ?', date).order('created_at DESC').each do |o|
      print o.id
      begin
        ticket_original_prices(o).each do |ph|
          load_downtown_price(ph[:id], ph[:original_price_fare], ph[:original_price_total])
        end
      rescue
      end
    end
  end

  def self.set_corrected_price_in_downtown_tickets
    PaperTrail.controller_info = {:done => 'filling in corrected_price in downtown tickets'}
    Order.FLL1S212V.where(ticket_status: 'ticketed').order('created_at DESC').each do |order|
      o = Order.find_by_id order.id
      if o.tickets.present? && o.tickets.all?{|t| t.kind == 'ticket' && t.status == 'ticketed' && t.original_price_fare_currency.present? && t.corrected_price == 0}
        o.tickets.each do |t|
          t.corrected_price = t.calculated_price_with_payment_commission
          t.save
        end
        o.update_prices_from_tickets
      end
    end
  end

  def self.create_price_migration_csv(date = Date.today - 11.month)
    ticket_hashes = Order.by_office_id('FLL1S212V').where(:ticket_status => 'ticketed').where('orders.created_at >= ?', date).inject([]) do |memo ,o|
      print o.id
      begin
        memo + ticket_original_prices(o).compact
      rescue
        memo
      end
    end
    CSV.open("tickets.csv", "wb") do |csv|
      ticket_hashes.each do |t|
        csv << t.values
      end
    end
  end

  def self.get_tz_from_lat_and_lng(lat, lng)
    xml = Net::HTTP.get URI.parse("http://ws.geonames.org/timezone?lat=#{lat}&lng=#{lng}&style=full")
    doc = REXML::Document.new xml
    doc.root.elements["timezone/timezoneId"].get_text.to_s
  end

  def self.fill_up_mongo_base
    Destination.limit(20).each do |d|
      attr_hash = {:to_iata => d.to_iata,
                  :from_iata => d.from_iata,
                   :rt => d.rt,
                   :average_price => d.average_price,
                   :average_time_delta => d.average_time_delta,
                   :hot_offers_counter => d.hot_offers_counter}
      dest = DestinationMongo.create(attr_hash)
  end
  HotOffer.limit(20).each do |h|
  attr_hash = {:code => h.code,
    :url => h.url,
    :description => h.description,
    :price => h.price,
    :for_stats_only => h.for_stats_only,
    :destination_id => h.destination_id,
    :time_delta => h.time_delta,
    :price_variation => h.price_variation,
    :price_variation_percent => h.price_variation_percent}
hot_offer = HotOfferMongo.create(attr_hash)
  end
  end

  def self.fill_in_timezones_for_cities
  City.find(:all, :conditions => 'timezone = "" and lat is not null and lng is not null and lat and lng').each do |c|
c.update_attribute :timezone, get_tz_from_lat_and_lng(c.lat, c.lng)
  sleep 0.5
  end
  end


def self.fill_in_morpher_fields(klass, first_id = 0)
    klass.all(:conditions => ['((proper_to = "") or (proper_to is NULL)) and (morpher_to is NULL or morpher_to = "") and (name_ru != "") and (name_ru is not NULL) and (id >= ?)', first_id]).each do |c|
      c.save_guessed
    end
  end

  def clear_morpher_fields
    [Country, City, Airport].each do |m|
      m.update_all("morpher_from = NULL, morpher_in = NULL, morpher_to = NULL")
      #City.update_all("morpher_from = NULL, morpher_in = NULL, morpher_to = NULL" , 'id < 1000 and id > 972')
    end
  end

  def self.fill_iata_destination_for_subscritions
    Subscription.find(:all).each do |sub|
      sub.update_attributes(:from_iata => sub.destination.from.iata,
                          :to_iata => sub.destination.to.iata,
                          :rt => sub.destination.rt)
    end
  end

  def self.fill_code_for_carriers
    Carrier.find(:all).each do |crr|
      tt = Ticket.where("code IS NOT NULL AND validating_carrier = ? ", crr.iata ).first
      if tt
        crr.update_attributes(:code => tt.code)
      end
    end
  end
  
  def self.fill_validating_carrier_for_tickets
    Ticket.where("validating_carrier IS NULL OR validating_carrier = ''").each do |ticket|
      tt = Carrier.where(:code => ticket.code).first
      if tt
        ticket.update_attributes(:validating_carrier => tt.iata)
      end
    end
  end

  ## Набор дата-миграций для приведения в порядок поля email в Order и Customer
  # 1. чистим поле email в ордере
  def self.trim_orders_email
    Order.update_all('email = TRIM(email)', 'email != TRIM(email)')
  end

  # 2. меняем всем разделители нескольких email на запятые
  def self.fix_orders_email_delim
    Order.update_all('email = REPLACE(email, ";", ",")', 'INSTR(orders.email, ";")')
  end

  # 3. перепривязываем ордер к кастомеру по первому email в поле, если он в ордере вдруг изменился
  def self.fix_customers_for_orders
    Order.joins(:customer).where('TRIM(orders.email) != "" AND SUBSTRING_INDEX(TRIM(orders.email), ",", 1) != customers.email').limit(200).each do |order|
      customer = Customer.find_or_initialize_by_email(order.first_email)
      customer.skip_confirmation_notification!
      customer.save unless customer.persisted?
      order.update_column(:customer_id, customer.id)
      #order.save
    end
  end

  # 4. удаляем кастомеров без единого ордера
  def self.delete_customers_without_orders
    Customer.without_orders.limit(200).each do |customer|
      customer.delete
    end
  end

  #5. Переводим email всех кастомеров в нижний регистр
  def self.lowercase_customers_email
    Customer.update_all('email = TRIM(LCASE(email))', 'BINARY LCASE(email) != email', :limit => 200)
  end

  # Заполняем базу кастомеров по старым заказам
  def self.fill_customers_for_orders
    Order.where("customer_id IS NULL AND email != ''").order("created_at DESC").limit(2000).each do |order|
      customer = Customer.find_or_initialize_by_email(order.first_email)
      customer.skip_confirmation_notification!
      customer.save unless customer.persisted?
      order.update_column(:customer_id, customer.id)
      #order.save
    end
  end


  def self.migrate_partners
    Conf.api.partners.each do |name|
      Partner.find_or_initialize_by_token(name).update_attributes(:enabled => true, :password => '')
    end
    Conf.api.passwords.each do |name, pass|
      Partner.find_or_initialize_by_token(name).update_attributes(:password => pass, :enabled => true)
    end
  end

  def self.recalculate_destination_false
    Destination.all.each do |d|
      d.recalculated = false
      d.save
    end
  end

  def self.recalculate_destination_average_price
    Destination.where(:recalculated => false).order_by([:hot_offers_counter, :desc]).limit(10).each do |d|
      hot_offers_count = d.hot_offers.count
      if hot_offers_count > 0
        d.average_price = d.hot_offers.every.price.sum / hot_offers_count
        d.average_time_delta = d.hot_offers.every.time_delta.sum / hot_offers_count
        d.hot_offers_counter = hot_offers_count
        d.recalculated = true
        d.save
        puts hot_offers_count
      else
        d.remove
      end
    end
  end
end


# encoding: utf-8
require "rexml/document"
require 'net/http'
require 'uri'
require 'csv'

# народ, помечайте миграции в PaperTrail! однажды может здорово пригодиться.

module DataMigration

  # set price acquiring compensation and price difference
  def self.upgrade_to_fee_schemas
    PaperTrail.controller_info = {:done => 'upgrade_to_fee_schemas'}
    Order.where(fee_scheme: '').order('created_at DESC').map do |o|
      o.fee_scheme = Conf.site.fee_scheme
      $tickets_are_loading = true
      o.tickets.every.save!
      $tickets_are_loading = false
      o.update_prices_from_tickets
    end
  end

  def self.fill_in_parent_pnr_number
    PaperTrail.controller_info = {:done => 'fill_in_parent_pnr_number'}
    orders = Order.where('(pnr_number is null or pnr_number = "") and (parent_pnr_number is null or parent_pnr_number = "") and payment_type = "card" and payment_status = "charged"').includes(:order_comments)
    orders.each do |o|
      parent_pnr_from_desc = o.description.scan(/\b([A-ZА-Я\d]{6})\b/)
      comment_text =  o.order_comments.every.text.join(' ')
      parent_ids = comment_text.scan(/\/orders\/show\/(\d+)/)
      raw_pnr_number = comment_text.scan(/\b([A-ZА-Я\d]{6})\b/)

      parent_pnr = ''
      if parent_pnr_from_desc.count == 1
        parent_pnr = parent_pnr_from_desc[0][0]
      elsif parent_ids.count == 1 && (parent = Order.find_by_id(parent_ids[0][0]))
        parent_pnr = parent.pnr_number
      elsif raw_pnr_number.count == 1
        parent_pnr = raw_pnr_number[0][0]
      end
      if parent_pnr.present?
        o.update_attributes(parent_pnr_number: parent_pnr)
      else
        print "** Got nothing #{o.id}: ", o.description, comment_text, "\n"
      end
    end
  end

  def self.set_price_with_payment_commission_in_tickets
    Order.order('id DESC').every.update_price_with_payment_commission_in_tickets
  end

  def self.set_status_in_refunds
    Ticket.update_all('status = "processed"', 'kind = "refund" AND processed = 1')
    Ticket.update_all('status = "pending"', 'kind = "refund" AND processed = 0')
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

  def self.price_migration_for_russian_offices
    Ticket.update_all "original_price_fare_cents = (price_fare * 100),
                       original_price_fare_currency = 'RUB',
                       original_price_tax_cents = (price_tax * 100),
                       original_price_tax_currency = 'RUB'", "office_id != 'FLL1S212V'"

  end

  def self.load_ticket_prices_form_csv
    CSV.foreach('tickets.csv') do |id, fare, total|
      Ticket.find(id).update_attributes(:original_price_total => total.to_money, :original_price_fare => fare.to_money)
    end
  end

  def self.create_price_migration_csv
    ticket_hashes = Order.by_office_id('FLL1S212V').where(:ticket_status => 'ticketed').where('orders.created_at >= ?', Date.today - 11.month).inject([]) do |memo ,o|
      print o.id
      begin
        memo + ticket_original_prices(o).compact
      rescue
        memo
      end
    end
    CSV.open("tickets.csv", "wb") do |csv|
      csv << ticket_hashes[0].keys
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

  def self.fill_customers_for_orders
    Order.where("customer_id IS NULL").limit(20).each do |order|
      customer_email = order.email.strip.split(/[,; ]/).first
      order.customer = Customer.find_or_create_by_email(customer_email)
      order.save
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


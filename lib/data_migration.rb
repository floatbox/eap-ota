# encoding: utf-8
require "rexml/document"
require 'net/http'
require 'uri'
require 'csv'

module DataMigration

  def self.update_blank_count
    Order.where('created_at >= ? AND pnr_number is not null AND blank_count is NULL and ticket_status = "ticketed"', Date.parse('01.06.2011')).map do |o|
      count = o.tickets.count
      o.update_attribute(:blank_count, count) if count > 0
    end
  end

  def self.update_price_blank_and_price_consolidator
    Order.where('created_at >= ? AND
     pnr_number is not null AND
     blank_count is not NULL AND
     blank_count > 0 AND
     ticket_status = "ticketed" AND
     source = "sirena" AND
     price_blanks = 0 AND
     price_consolidator = 0 AND
     price_consolidator_markup > 0', Date.parse('01.06.2011')).each do |o|
      o.update_attribute(:price_blanks, 50 * o.blank_count)
      o.update_attribute(:price_consolidator, o.price_consolidator_markup - (50 * o.blank_count))
    end
  end

  def self.fill_in_ticketed_date_in_sirena_tickets
    orders = Order.where(['source = "sirena" AND created_at > ? AND ticket_status = "ticketed"', Date.today - 1.month]).order('created_at DESC')
    orders.each do |o|
      ticket_dates = Sirena::Service.new.pnr_status(o.pnr_number).tickets_with_dates
      ticket_dates.each do |number, date|
        ticket = o.tickets.find_by_number(number)
        ticket.update_attribute(:ticketed_date, date) if ticket
      end
    end
  end

  def self.fill_in_ref_in_payments
    Payment.all(:conditions => 'ref = "" OR ref is NULL').each do |p|
      p.update_attribute(:ref,  Conf.payment.order_id_prefix + p.id.to_s)
    end
  end

  def self.fill_in_code_in_tickets
    Ticket.all.each do |t|
      number = t.number
      t.update_attributes(:code => (number.match(/([\d\w]+)-{0,1}(\d{10}-{0,1}\d*)/).to_a)[1],
                          :number => (number.match(/([\d\w]+)-{0,1}(\d{10}-{0,1}\d*)/).to_a)[2]
                          ) if t.code.blank?
    end
  end

  def self.update_route_in_tickets
    Ticket.all.each do |t|
      t.route = t.order.route
    end
  end

  def self.load_tickets
    orders = Order.where('ticket_status = "ticketed"')
    orders.each do |order|
      order.load_tickets
    end
    Ticket.all.each do |t|
      t.update_attribute(:created_at, t.order.ticketed_date)
    end
  end


  def self.update_iata_ru_in_carriers_and_airplanes(path)
    open("#{path}/airplanes.csv").each_line do |row|
      row.chomp
      iata, iata_ru, *smth = row.split(';')
      airplane = Airplane.find_by_iata(iata)
      airplane.update_attribute(:iata_ru, iata_ru) if airplane && airplane.iata_ru.blank? && (iata_ru != iata)
    end
    open("#{path}/carriers.csv").each_line do |row|
      row.chomp
      iata, iata_ru, name_en, country_code, name_ru = row.split(';')
      carrier = Carrier.find_by_iata(iata) || Carrier.find_by_ru_shortname(name_ru) || Carrier.find_by_en_shortname(name_en)
      carrier.update_attribute(:iata_ru, iata_ru) if carrier && (iata != iata_ru)
    end
  end

  def self.update_iata_ru
    cities = City.all(:conditions => 'iata_ru is NOT null and iata_ru != ""')
    cities.each do |c|
      if c.airports.count == 1 && c.airports.first.iata_ru.blank?
        c.airports.first.update_attribute(:iata_ru, c.iata_ru)
      elsif  c.airports.count == 0
        Airport.create(:name_en => c.name_en, :name_ru => c.name_ru, :iata => c.iata, :iata_ru => c.iata_ru, :city => c, :morpher_in => c.morpher_in, :morpher_from => c.morpher_from, :morpher_to => c.morpher_to)
      end
    end
  end


  def self.update_cities_with_sirena_data(path)
    open(path + '/cities.csv').each_line do |l|
      l.chomp
      iata, iata_ru, name_en, name_ru, country_id, region_id, lat, lng, morpher_to, morpher_from, morpher_in = l.split(';')
      if iata_ru && iata_ru.match(/[А-Я]/u)
        city = City.find_by_iata(iata)
        city = City.find_by_name_ru(name_ru) if !city && country_id == 'RU'
        if city
          city.update_attribute(:sirena_name, name_ru) if name_ru != city.name_ru
          city.update_attribute(:iata_ru, iata_ru)
        else
          country = Country.find_by_alpha2(country_id) || Country.find_by_id(country_id)
          if country && (iata =~ /^[A-Z]+$/) && lat.present?
            City.create(:iata => iata, :iata_ru => iata_ru,
                        :name_en => name_en, :name_ru => name_ru,
                        :country => country, :lat => lat, :lng => lng,
                        :morpher_to => morpher_to, :morpher_from => morpher_from,
                        :morpher_in => morpher_in)
          end
        end
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
      attr_hash = {:to_iata => (City.find(d.to_id)).iata,
                   :from_iata => (City.find(d.from_id)).iata,
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

end


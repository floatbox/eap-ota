# encoding: utf-8
require "rexml/document"
require 'net/http'
require 'uri'
require 'csv'

module DataMigration

  def self.update_blank_count
    Order.where(:blank_count => nil).includes(:tickets).all.each do |order|
      order.blank_count = order.tickets.any? && order.tickets.size
      order.save
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

end


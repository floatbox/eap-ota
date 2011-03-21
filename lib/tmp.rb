# encoding: utf-8
require "rexml/document"
require 'net/http'
require 'uri'

module Tmp


  def self.create_payments_for_existing_orders
    Order.all.each do |o|
      Payment.create(:price => o.price_with_payment_commission, :last_digits_in_card => o.last_digits_in_card, :order => o, :name_in_card => o.name_in_card, :id_override => o.order_id)
    end
  end

  def self.fill_in_disabled_flag_in_cities_and_airports
    Amadeus.booking do |amadeus|
      City.all(:conditions => 'iata != ""  and iata is not null').each do |c|
        res = amadeus.cmd("dac #{c.iata}")
        c.update_attribute(:disabled, true) if res['LOCATION NOT IN TABLE']
        sleep 0.5
      end
      Airport.all(:conditions => 'iata != ""  and iata is not null').each do |c|
        res = amadeus.cmd("dac #{c.iata}")
        c.update_attribute(:disabled, true) if res['LOCATION NOT IN TABLE']
        sleep 0.5
      end

    end
  end

  def self.fill_in_lat_and_lng_in_regions
    Region.all.each do |r|
      city = City.first(:conditions => ['region_id = ?', r.id], :order => 'importance DESC')
      r.update_attributes(:lat => city.lat, :lng => city.lng)
    end
  end

  def self.fill_in_iata_ru_in_cities_and_airports(path)
    open(path + '/cities.csv').each_line do |l|
      l.chomp
      iata, iata_ru, name_en, name_ru, country_id, region_id, lat, lng, morpher_to, morpher_from, morpher_in = l.split(';')
      if iata_ru.match(/[А-Я]/u)
        city = City.find_by_iata(iata)
        city = City.find_by_name_ru(name_ru) if !city && country_id == 'RU'
        if city
          city.update_attribute(:sirena_name, name_ru) if name_ru != city.name_ru
          city.update_attribute(:iata_ru, iata_ru)
        end
      end
    end
    open(path + '/airports.csv').each_line do |l|
      l.chomp
      iata, iata_ru, name_en, name_ru, city_id, lat, lng, morpher_to, morpher_from, morpher_in = l.split(';')
      if iata_ru.match(/[А-Я]/u)
        airport = Airport.find_by_iata(iata)
        airport = Airport.find_by_name_ru(name_ru) if !airport
        if airport
          airport.update_attribute(:sirena_name, name_ru) if name_ru != airport.name_ru
          airport.update_attribute(:iata_ru, iata_ru)
        end
      end
    end
  end

  def self.fill_in_cities_and_airports
    open('config/cities.csv').each_line do |l|
      l.chomp
      next if l =~ /^\s*$/
      next if l =~ /^#/
      code, name_en, name_ru = l.split(';')
      city = City.find_by_iata(code)
      city.update_attributes(:name_en => name_en, :name_ru => name_ru) if city
    end
    open('config/airports.csv').each_line do |l|
      l.chomp
      next if l =~ /^\s*$/
      next if l =~ /^#/
      code, name_en, name_ru = l.split(';')
      airport = Airport.find_by_iata(code)
      airport.update_attributes(:name_en => name_en, :name_ru => name_ru) if airport
    end

  end

  def self.fill_in_regions_and_clean_cities
    usa = Country.find_by_name_en("United States")
    City.all.each do |c|
      if c.name_ru && c.name_ru[', шт. '] && c.name_ru.split(',').length == 2 && c.name_en && c.name_en.split(',').length == 2
        city_name_ru, name_ru = c.name_ru.chomp.split(', шт. ')
        city_name_en, name_en = c.name_en.split(', ')
        r = Region.find_or_create_by_name_ru(name_ru)
        r.name_en = name_en
        r.country = usa
        r.save
        c.name_ru = city_name_ru
        c.name_en = city_name_en
        c.region = r
        c.save
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


require "rexml/document"
require 'net/http'
require 'uri'

module Tmp
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
end
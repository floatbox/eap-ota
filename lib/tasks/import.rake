# encoding: utf-8
# Field 01 - ICAO Code: 4 character ICAO code
# Field 02 - IATA Code: 3 character IATA code
# Field 03 - Airport Name: string of varying length
# Field 04 - City,Town or Suburb: string of varying length
# Field 05 - Country: string of varying length
# Field 06 - Latitude Degrees: 2 ASCII characters representing one numeric value
# Field 07 - Latitude Minutes: 2 ASCII characters representing one numeric value
# Field 08 - Latitude Seconds: 2 ASCII characters representing one numeric value
# Field 09 - Latitude Direction: 1 ASCII character either N or S representing compass direction
# Field 10 - Longitude Degrees: 2 ASCII characters representing one numeric value
# Field 11 - Longitude Minutes: 2 ASCII characters representing one numeric value
# Field 12 - Longitude Seconds: 2 ASCII characters representing one numeric value
# Field 13 - Longitude Direction: 1 ASCII character either E or W representing compass direction
# Field 14 - Altitude: varying sequence of ASCII characters representing a numeric value corresponding to the airport's altitude from mean sea level (ie: "123" or "-123")

namespace :import do
  task :airports => :environment do
    require 'csv'
    counter = 0
    CSV.open 'tmp/GlobalAirportDatabase.txt', 'r', ?: do |row|
      icao, iata, name_en, city, country = *row

      a = Airport.find_or_initialize_by_icao(icao)

      a.iata = (iata == 'N/A' ? nil : iata)
      a.name_en = name_en
      a.city = city
      a.country = country
      a.save!

      counter += 1
      puts counter if (counter % 100).zero?
    end
  end

  task :russian_airports => :environment do
  # Абакан (Хакасия)  ABA   UNAA  АБН   Абакан  3250 м  межд., фед. знач.
    counter = 0
    File.open('tmp/russian_airports.txt', 'r').each_line do |line|
      line.chomp!
      city_and_region, iata, icao, domestic, name_ru, runway_length, status = line.split(/ ?\t/)
      next unless icao
      a = Airport.find_or_create_by_icao(icao)

      if city_and_region.match(/(.*) \((.*\))/)
        city_ru = $1;
        region_ru = $2
      end

      international = (status && !status['межд.'].nil?)

      federal = (status && !status['фед.'].nil?)

      runway_length = runway_length.to_i unless runway_length.blank?

      a.update_attributes! :city_ru => city_ru,
        :region_ru => region_ru,
        :iata => iata,
        :domestic => domestic,
        :name_ru => name_ru,
        :runway_length => runway_length,
        :federal => federal,
        :international => international,
        :country => 'RUSSIA'

      counter += 1
      puts counter if (counter % 10).zero?

    end
    puts "total airports: #{Airport.count}"
  end


  # Adria Airways           JP      165     ADR     Slovenia
  # Adria Airways - The Airline of Slovenia D.D.
  # Kuzmiceva 7
  # Ljubljana ,
  # Slovenia
  # 1000
  # http://www.adria.si

  task :carriers => :environment do
    carrier = nil
    counter = 0
    open('tmp/airline_members_list.txt', 'r').each_line do |line|

      line.chomp!
      if carrier.nil?
        short_name, iata, digit, icao, country = line.split(/  +/)
        carrier = Carrier.new(
          :short_name => short_name,
          :iata => iata,
          :digit => digit,
          :icao => icao,
          :country => country,
          :address => ''
        )

      elsif carrier.long_name.blank?
        carrier.long_name = line

      elsif line['http://']
        carrier.site = line
        carrier.save!
        carrier = nil

        counter += 1
        puts counter if (counter % 100).zero?

      else
        carrier.address += line + ' '
      end

    end
  end

  task :airplanes => :environment do
    counter = 0
    File.open('tmp/aircrafts.txt', 'r').each_line do |line|
      line.chomp!
      next if line =~ /^#/
      iata, icao, name_en, wake_category = line.split(/ ?\t ?/)

      next if name_en =~ /Freighter/
      name_en.sub!(/ ?[pP]ax/, '')
      name_en.strip!

      icao = nil if icao == 'n/a'

      a = Airplane.find_or_create_by_iata(iata)

      a.update_attributes! :icao => icao,
        :name_en => name_en,
        :wake_category => wake_category

      counter += 1
      puts counter if (counter % 10).zero?

    end
    puts "total airplanes: #{Airplane.count}"
  end

  task :countries => :environment do
    require 'csv'
    require 'open-uri'
    open('http://www.artlebedev.ru/tools/country-list/tab/').each_with_index do |line, counter|
      next if counter == 0
      row = CSV.parse_line(line, ?\t)
      # name fullname english alpha2 alpha3 iso location location-precise
      fields = Hash[
        [ :name_ru,
          :full_name_ru,
          :name_en,
          :alpha2,
          :alpha3,
          :iso,
          :continent_ru,
          :continent_part_ru
        ].zip(row)
      ]

      c = Country.find_or_initialize_by_alpha2(fields[:alpha2])
      c.update_attributes! fields

      counter += 1
      puts counter if (counter % 10).zero?
    end
  end

  task :awad_cities => :environment do
    #City.delete_all
    require 'open-uri'
    require 'nokogiri'

    country_mapping = {
      'Корея (Северная), КНДР' => 'Северная Корея',
      'Корея (Южная)' => 'Южная Корея',
      'Великобритания' => 'Соединенное Королевство',
      'США' => 'Соединенные Штаты',
      'Сербия, Сербия' => 'Сербия',
      'Иран' => 'Иран, Исламская Республика',
      'Кокосовые острова' => 'Кокосовые (Килинг) острова',
      'Марианские острова' => 'Северные марианские острова',
      'Палестина' => 'Палестинская территория, оккупированная',
      'Кот-д\'Ивуар' => 'Кот д\'Ивуар',
      'Чехия' => 'Чешская Республика',
      'Македония' => 'Республика Македония',
      'Гвиана' => 'Французская Гвиана',
      'Каймановы острова' => 'Острова Кайман',
      'Гвинея-Биссау' => 'Гвинея-Бисау',
      'Центральноафриканская Республика' => 'Центрально-Африканская Республика',
      'Тайвань' => 'Тайвань (Китай)',
      'Танзания' => 'Танзания, Объединенная Республика',
      'Сирия' => 'Сирийская Арабская Республика',
      'Микронезия' => 'Микронезия, Федеративные Штаты',
      'Полинезия' => 'Французская Полинезия',
      'Антильские острова' => 'Нидерландские Антилы',
      'Сейшельские острова' => 'Сейшелы',
      'Фолклендские острова' => 'Фолклендские острова (Мальвинские)',
      'Молдавия' => 'Молдова, Республика',
      'Белоруссия' => 'Беларусь',
      'Восточный Тимор' => 'Тимор-Лесте',
      'Майотт' => 'Майотта',
      'Ливия' => 'Ливийская Арабская Джамахирия',
      'Бруней' => 'Бруней-Даруссалам',
      'Коморские острова' => 'Коморы',
      'Малые острова США' => 'Соединенные Штаты',
      'Виргинские острова' => 'Виргинские острова, Британские',
      'Конго Республика' => 'Конго',
      'Южно-Африканская Республика' => 'Южная Африка',
      'Туркменистан' => 'Туркмения'
    }

    unrekognized = {}

    base_url = 'http://www.anywayanyday.com/cities/'
    headers = {
      'Referer' => base_url,
      'User-Agent' => 'Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.6; en-US; rv:1.9.1.5) Gecko/20091102 Firefox/3.5.5'
    }

    doc = Nokogiri::HTML(open('http://www.anywayanyday.com/cities/', headers))

    changed_counter = 0
    created_counter = 0
    counter = 0

    doc.css('.GroupList a').each_with_index do |link, counter|
      city_url = link.attribute("href").text
      iata = city_url.split('/')[2]
      name_ru, country_ru = link.text.split(/,\s*/, 2)

      country_ru = country_mapping[country_ru] if country_mapping[country_ru]

      country = Country.find_by_name_ru(country_ru)
      unless country
        unrekognized[country_ru] = true
        next
      end

      city = City.find_or_initialize_by_iata(iata)
      city.country = country
      city.attributes = { :name_ru => name_ru }
      if city.new_record?
        created_counter += 1
      elsif city.changed?
        changed_counter += 1
      end
      city.save!

      begin
        city_doc = Nokogiri::HTML(open("#{base_url}#{city.iata}", headers))

        begin
          # не всегда есть
          city.lat = city_doc.css('#CityLatitude').attribute('latitude').text
          city.lng = city_doc.css('#CityLongitude').attribute('longitude').text
          city.save!
        rescue
          puts "no lat lng for city #{city.name}"
        end

        city_doc.css('#AirportList li').each do |li|
          ap_iata =  li.attribute('code').text
          ap_name = li.css('.AirportName').first.text
          ap_lat =  li.attribute('latitude').text
          ap_lng = li.attribute('longitude').text

          if ap_name =~ /[A-Z]/
            ap_name_en = ap_name
          else
            ap_name_ru = ap_name
          end

          airport = Airport.find_or_initialize_by_iata(ap_iata)

          airport.city = city

          airport.name_ru = ap_name_ru if ap_name_ru
          airport.name_en = ap_name_en if ap_name_en
          airport.lat = ap_lat
          airport.lng = ap_lng
          airport.save!
        end
        # сделать что-то со страницей города
      rescue OpenURI::HTTPError
        puts "404 for city #{city.name_ru} #{city_url}"
      end

      puts counter if counter % 10 == 0
    end

    puts "Городов сзвижжено: #{counter}"
    puts "Городов создано: #{created_counter}, обновлено: #{changed_counter}"
    puts "Городов всего: #{City.count}"

    unless unrekognized.empty?
      puts "неизвестные страны:"
      unrekognized.keys.each {|key| puts key}
    end

  end

end


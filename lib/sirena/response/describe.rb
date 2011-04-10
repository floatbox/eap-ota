# encoding: utf-8
require 'csv'
module Sirena
  module Response
    class Describe < Sirena::Response::Base

      attr_accessor :datas, :data_type

      def parse
        self.datas = []
        self.data_type = at_xpath("//describe")["data"]
        xpath("//describe/data").each do |data|
          d = {}
          data.children.each{|ch|
            unless ch.name.blank? || ch.name.strip.blank?
              name = ch.name.strip.to_sym
              lang = ch["lang"]
              if !lang.blank?
                lang = lang.strip.to_sym
                d[name] = {} if d[name].blank?
                d[name][lang] = ch.text
              elsif !ch.children.blank?
                d[name]={}
                ch.children.each{|subclass|
                  klass = subclass["class"]
                  if klass
                    klass.strip!
                    d[name][klass] ||= []
                    d[name][klass] << subclass.text
                  end
                }
              else
                d[name] = ch.text
              end
            end
          }
          self.datas << d
        end
      end

      # генерирует csv с результатами
      # если указан filename пишет его в файлег
      def generate_csv(filename=nil)
        cl = case @data_type
        when 'airport' then Airport
        when 'city' then City
        when 'aircompany' then Carrier
        when 'vehicle' then Airplane
        end

        columns = case @data_type
        when 'airport' then ["iata", "iata_ru", "name_en", "name_ru", "city_id", "lat", "lng","morpher_to", "morpher_from", "morpher_in"]
        when 'city' then ["iata", "iata_ru", "name_en", "name_ru", "country_id", "region_id", "lat", "lng", "morpher_to", "morpher_from", "morpher_in"]
        when 'aircompany' then ["iata", "iata_ru", "en_shortname", "country_id", "ru_shortname"] #  "en_longname", "ru_longname"
        when 'vehicle' then ["iata", "iata_ru", "name_en", "name_ru", "engine_type"]
        end
        hash = cl.all.group_by(&:iata)

        result = ""

        cities = City.all.group_by(&:iata) if columns.include?("city_id")
        countries = Country.all.group_by(&:alpha2) if columns.include?("country_id")
        CSV::Writer.generate(result, ';') do |csv|
          csv << columns
          @datas.each{|data|
            value = {"iata"=>data[:code][:en], "iata_ru"=>data[:code][:ru]}

            name_ru = wcapitalize(data[:name][:ru])
            name_en = wcapitalize(data[:name][:en])
            if columns.include?("name_ru")
              value["name_en"] = name_en
              value["name_ru"] = name_ru
            end
            if columns.include?("en_shortname")
              value["en_shortname"] = name_en
              value["ru_shortname"] = name_ru
            end

            orig = hash[data[:code][:en]] && hash[data[:code][:en]][0]
            if !orig
              without_state = name_ru.mb_chars.gsub(/\([^)]+\)/u, "").strip.to_s
              if columns.include?("morpher_to")
                value["morpher_to"] = make_case(without_state, "to")
                value["morpher_in"] = make_case(without_state, "in")
                value["morpher_from"] = make_case(without_state, "from")
              end
              if columns.include?("city_id")
                city = City[data[:city][:en]]
                if city.blank?
                  puts "нет города "+data.inspect
                  next
                end
                value["city_id"]=data[:city][:en]
              end
              if columns.include?("country_id")
                id = data[:country] && data[:country][:en]
                country = value["city_id"] ? city.country : countries[id] && countries[id][0]
                if country
                  value["country_id"] = country.id
                else
                  puts "нет страны "+data.inspect
                end
              end
              if columns.include?("lat")
                str = country ? country.name_ru+", " : ""
                str+= (city && city.id) ? city.name_ru+", " : ""
                str+=name_ru
                value["lat"], value["lng"] = find_coords(str)
              end
              if columns.include?("region_id")
                match = name_ru.mb_chars.match(/\(шт.([^)]+)\)/u)
                value["region_id"]=match && match[0].strip.to_s
              end
            else
              if columns.include?("morpher_to")
                value["morpher_to"] = orig.morpher_to
                value["morpher_in"] = orig.morpher_in
                value["morpher_from"] = orig.morpher_from
              end
              if columns.include?("city_id")
                value["city_id"]=orig.city.iata
              end
              if columns.include?("country_id")
                value["country_id"] = orig.country && orig.country.alpha2
              end
              if columns.include?("lat")
                value["lat"] = orig.lat
                value["lng"] = orig.lng
              end
              if columns.include?("region_id")
                match = name_ru.mb_chars.match(/\(шт.([^)]+)\)/u)
                value["region_id"]= orig.region && orig.region.name_ru || match && match[0].strip.to_s
              end
            end

            csv << columns.map{|col| value[col]}
          }
        end
        unless filename.blank?
          File.open(filename, "w").puts result
        end
        result
      end

      def find_coords(str)
        resp = Net::HTTP.get(URI.parse(URI.encode("http://maps.yandex.ru/?text="+str)))
         m = resp.match(/"ll":\[([^,]+),([^\]]+)\]/)
         if m
           [m[1].to_f,m[2].to_f]
        end
      end

      # оно приходит написанное всеми заглавными буквами. оставляем заглавными только первые
      def wcapitalize(str)
        str.gsub(/[^ .-]+/u) {|s| s.mb_chars.capitalize.to_s}.strip
      end

      # тупой склонятор, я нашла ваш, но слишком поздно :о(
      # видимо, надо переделать
      def make_case(str, which_case)
        prefix = case which_case
          when "in", "to" then "в"+(str.first.match(/[ВФ][бвгджзклмнпрстфхцчшщъь]/u) ? "о" : "" )
          when "from" then "из"
          end
        index=["from", "to", "in"].index(which_case)
        pre_last = str.mb_chars[-2...-1]
        last = case str.last
          when "а" then ["ы", "у", "е"]
          when "е", "и", "о", "у", "ю" then [str.last, str.last, str.last]
          when "ы" then ["", "ы", "ах"]
          when "ь" then ["и", "ь", "и"]
          when "я" then
            case pre_last
            when "a" then
              pre_last=""
              ["ой", "ую", "ой"]
            else
              ["и", "ю", "и"]
            end
          when "й" then
            case pre_last
            when "и", "ы" then
              was = pre_last
              pre_last=""
              ["ого", was+"й", "ого"]
            else
              ["я", "й", "е"]
            end
          else
            [str.last+"а", str.last, str.last+"е"]
          end[index]
        prefix+" "+ str.mb_chars[0...-2].to_s+pre_last+last
      end
    end
  end
end


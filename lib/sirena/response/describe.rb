# encoding: utf-8
module Sirena
  module Response
    class Describe < Sirena::Response::Base

      attr_accessor :datas, :data_type

      def initialize(*)
        super
        self.datas = []
        descr = xpath("//describe")[0].attribute("data")
        self.data_type = descr && descr.value
        xpath("//describe/data").each do |data|
          d = {}
          data.children.each{|ch|
            unless ch.name.blank? || ch.name.strip.blank?
              name = ch.name.strip.to_sym
              lang = ch.attribute("lang") && ch.attribute("lang").value
              if !lang.blank?
                lang = lang.strip.to_sym
                d[name] = {} if d[name].blank?
                d[name][lang] = ch.text
              else
                d[name] = ch.text
              end
            end
          }
          self.datas << d
        end
      end

      # генерирует руби код, который, выполняясь, заполняет базу
      # если указан filename пишет его в файлег
      def generate_update_code(filename=nil)
        cl = case @data_type
        when 'airport' then Airport
        when 'city' then City
        end

        hash = cl.all.group_by(&:iata)
        orig = []
        dup = []
        @datas.each{|data| next if data[:name][:en].strip.blank?
          c = hash[data[:code][:en]]
          if c then
            data[:amad]=c[0]
            dup << data
          else
            orig << data
          end
        }

        result = ""

        cities = City.all.group_by(&:iata) if @data_type == 'airport'

        orig.each{|data|
          name_ru = wcapitalize(data[:name][:ru])
          without_state = name_ru.mb_chars.gsub(/\([^)]+\)/u, "").strip.to_s
          to = make_case(without_state, "to")
          c_in = make_case(without_state, "in")
          from = make_case(without_state, "from")
          name_en = wcapitalize(data[:name][:en])
          if @data_type == 'airport'
            city = cities[data[:city][:en]]
            if city.blank?
              puts "нет города "+data.inspect
              next
            end
            city=city[0]
            country = city.country
            str = country.name_ru+", "+(city.sirena_name && city.sirena_name != "original" ? city.sirena_name : city.name_ru)+", "+without_state
            lat,lng=find_coords(str)
            result+="Airport.create({:iata=>\"#{data[:code][:en]}\", :iata_ru=>\"#{data[:code][:ru]}\", :name_en=>\"#{name_en}\", \
:name_ru=>\"#{name_ru}\", :city_id=>#{city.id}, :sirena_name=>\"original\", \
:morpher_to=>\"#{to}\", :morpher_from=>\"#{from}\", :morpher_in=>\"#{c_in}\", :lat=>#{lat || 'nil'}, :lng=>#{lng || 'nil'}})\n"
          else
            country = Country.find_by_alpha2(data[:country][:en])
            str = country ? country.name_ru+", " : ""
            lat,lng = find_coords(str+name_ru)
            tzone = "Etc/GMT"+data[:timezone].gsub("+0", "+").gsub("-0", "-").gsub(/0?:../, "")
            country = country.id if country
            result+="City.create({:iata=>\"#{data[:code][:en]}\", :iata_ru=>\"#{data[:code][:ru]}\", :name_en=>\"#{name_en}\", \
:name_ru=>\"#{name_ru}\", :country_id=>#{country || 'nil'}, :timezone=>\"#{tzone}\", :sirena_name=>\"original\", \
:morpher_to=>\"#{to}\", :morpher_from=>\"#{from}\", :morpher_in=>\"#{c_in}\", :lat=>#{lat || 'nil'}, :lng=>#{lng || 'nil'}})\n"
          end
        }

        dup.each{|data|
          sirena_name = wcapitalize(data[:name][:ru])
          result+="#{cl.name}[\"#{data[:code][:en]}\"].update_attributes({:iata_ru=>\"#{data[:code][:ru]}\"#{', :sirena_name=>"'+sirena_name+'"' if sirena_name!=data[:amad].name_ru}})\n"
        }

        unless filename.blank?
          File.open(filename, "w").puts result
        end
        result
      end

      # тупо берем первые координаты с яндекса (потому что много русских городов)
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
          when "in", "to" then "в"+(str.first.match(/[ВФ]/u) ? "о" : "" )
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

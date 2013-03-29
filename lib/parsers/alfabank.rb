# encoding: utf-8
module Parsers
  class Alfabank

    def initialize(doc, filename)
      @filename = filename
      @doc = doc.dup.force_encoding('windows-1251').encode('utf-8')
    end

    TZ = ActiveSupport::TimeZone.new('Europe/Moscow')

    MAPPING = {
      # Дата
      date: 0..7,
      # Время
      time: 10..14,
      # Код авторизации: 18..28,
      # Тип опер.
      type: 30..34,
      # Номер карты
      pan: 37..54,
      # Сумма операции
      price: 77..91,
      # Комиссия с фирмы
      commission: 100..116,
      # Карт. прогр.: 117..122,
      # Тип устр-ва: 124..127,
      # Номер устр-ва: 132..136,
      # BO UTRNNO: 140..151,
      # FE UTRNNO: 155..166,
      ##  Итоги по группе, бывают в начале каждой группы операций
      # Тип  опер.: 172..175,
      # Платежная  система: 179..200,
      # Сумма операции: 204..217,
      # Комиссия с фирмы: 228..243
    }

    def parse
      charged_on = parse_charged_on(@doc)
      rows = []
      @doc.each_line do |line|
        #если кончился мусор и пошли наши столбцы, начинаются на дату, всегда
        #next unless line.match(/^(0[1-9]|[12][0-9]|3[01])\.(0[1-9]|1[012])\.\d\d/)
        next unless line.match(/^\d\d\.\d\d.\d\d/)
        rows << parse_line(line, charged_on)
      end
      rows
    end

    def parse_line(line, charged_on)
      fields = {}
      MAPPING.each do |key, range|
        fields[key] = line[range].to_s.strip
      end
      row = {}
      row[:charged_on] = charged_on
      row[:created_at] = parse_datetime(fields[:date], fields[:time])
      row[:price] = BigDecimal.new(fields[:price])
      row[:commission] = BigDecimal.new(fields[:commission])
      row[:earnings] = row[:price] - row[:commission]
      row[:pan] = parse_pan( fields[:pan] )
      row[:kind] =
        case fields[:type]
        when '5', '50'
          :charge
        when '6', '60'
          :refund
        else
          raise "unknown operation type #{row[:type].inspect}"
        end
      row
    end

    def display
      @doc
    end

    private

    def parse_charged_on(contents)
      # строка "обработанных с 18.09.2012 по 18.09.2012"
      unless contents =~ /^\s+обработанных с ([\d\.]+) по ([\d\.]+)/
        return
        # raise "can't find charge date"
      end
      unless $1 == $2
        return
        # raise "don't know exact charge date for sure for #{$1}..#{$2}"
      end
      date = $1
      dd, mm, yy = date.split(/\D/).map(&:to_i)
      Date.new(yy, mm, dd)
    end

    def parse_datetime(date, time)
      dd, mm, yy = date.split(/\D/).map(&:to_i)
      hh, ss = time.split(':').map(&:to_i)
      # рассчет на то, что это москва унас
      TZ.local(2000+yy, mm, dd, hh, ss)
    end

    def parse_pan(maybe_broken_pan)
      case maybe_broken_pan
      when /^\d{6}X{6}\d{4}$/
        return maybe_broken_pan
      # таких много, убираю лишний знак
      when /^\d{6}X{7}\d{4}$/
        return maybe_broken_pan.sub('X', '')
      # два таких документа, возвращаю маску для like
      when /^(\d{6})\*X{6}(\d{3})$/
        return "#{$1}XXXXXX_#{$2}"
      else
        raise "strange pan #{maybe_broken_pan.inspect}"
      end
    end

  end
end

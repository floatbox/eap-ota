# encoding: utf-8
module TranslationHelper

  private

  NBSP = "\u00a0"
  # меняет первый пробел на юникодный nbsp; для красоты предлогов
  def nbsp_first string
    string.sub(/ +/, NBSP)
  end

  # localized places and objects from database
  # Usage:
  #   <%= dict city %>
  #   dict airport, :from
  #   dict [airport1, airport2, city3], :in
  def dict(object, format=:name)

    if object.kind_of? Array
      return object.map {|item| dict(item, format) }.to_sentence
    end

    translation =
      case I18n.locale
      when :ru

        case object
        when Country, Region, City, Airport
          case format
          when :name
            object.name_ru
          when :from, :to, :in
            nbsp_first( object.send("case_#{format}") )
          end
        when Airplane
          # object.iata нужно для автогенеренных самолетов
          # консерн такой: лучше показать iata, чем падать с 500й
          logger.info "No name_ru found for airplane #{object.iata}" unless object.name_ru
          object.name_ru || object.iata
        when Carrier
          case format
          when :name
            # FIXME не очень круто
            object.ru_shortname.presence || object.en_shortname
          when :long
            object.ru_longname
          end
        end

      when :en
        case object
        when Country, Region, City, Airport
          case format
          when :name
            object.name_en
          when :from, :to, :in
            nbsp_first("#{format} #{object.name_en}")
          end
        when Airplane
          # см. выше с :ru
          logger.info "No name_en found for airplane #{object.iata}"
          object.name_en || object.iata
        when Carrier
          case format
          when :name
            object.en_shortname
          when :long
            object.en_longname
          end
        end
      end

    unless translation
      raise NotImplementedError, "no translation for #{I18n.locale} #{object.class}##{object.id} :#{format}"
    end

    return translation
  end

  # Sort by localized name
  def sort_by_name(items)
    items.sort_by {|i| dict(i) }
  end

  # Amount of adults, children and infants
  def human_people(adults, children, infants)
    a = I18n.t('results.header.adults')[adults - 2] if adults > 1
    c = I18n.t('results.header.children')[children - 1] if children > 0
    i = I18n.t('results.header.infants')[infants - 1] if infants > 0
    case I18n.locale
    when :ru
      return [a, c, i].compact.to_sentence(:words_connector => ' ', :two_words_connector => c && i ? I18n.t('nbsp_and') : ' ')
    else
      return [a, c, i].compact.join(', ')
    end
  end

end

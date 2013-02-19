module TranslationHelper
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
            object.send "case_#{format}"
          end
        when Airplane
          object.name_ru
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
            "#{format} #{object.name_en}"
          end
        when Airplane
          object.name_en
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
    case I18n.locale
    when :ru
      return items.sort_by(&:name_ru)
    when :en
      case items.first
      when Carrier
        return items.sort_by(&:en_shortname)
      else
        return items.sort_by(&:name_en)
      end
    end
    return items
  end
  
  # Amount of adults, children and infants
  def human_people(adults, children, infants)
    a = t('results.header.adults')[adults - 2] if adults > 1
    c = t('results.header.children')[children - 1] if children > 0
    i = t('results.header.infants')[infants - 1] if infants > 0
    case I18n.locale
    when :ru
      return [a, c || i ? [c, i].compact.join(t('nbsp_and')) : nil].compact.join(' ')
    when :en
      return [a, c, i].compact.join(', ')
    end  
  end
  
end

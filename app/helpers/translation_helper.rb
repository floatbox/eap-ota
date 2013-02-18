module TranslationHelper
  # localized places and objects from database
  # Usage:
  #   <%= dict city %>
  #   dict airport, :from
  def dict(object, format=:name)
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
  
  def sort_by_name(items)
    case I18n.locale
    when :ru
    
    when :en
    
    end
  end
  
end

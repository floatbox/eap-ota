module TranslationHelper
  # localized places and objects from database
  # Usage:
  #   <%= dict city %>
  #   dict airport, :from
  def dict(object, format=:short)
    translation =
      case I18n.locale
      when :ru

        case object
        when City, Region, Airport, Airplane
          case format
          when :short
            object.name_ru
          when :from, :to, :in
            object.send "case_#{format}"
          end
        when Carrier
          case format
          when :short
            object.ru_shortname
          when :long
            object.ru_longname
          end
        end

      when :en
        case object
        when City, Region, Airport, Airplane
          case format
          when :short
            object.name_en
          when :from, :to, :in
            "#{format} #{object.name_en}"
          end
        when Carrier
          case format
          when :short
            object.en_shortname
          when :long
            object.en_longname
          end
        end
      end

    unless translation
      raise NotImplementedError, "no translation for #{I18n.locale} #{object.class} #{format}"
    end

    return translation
  end
end

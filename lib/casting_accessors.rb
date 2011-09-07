# encoding: utf-8

# параметры от форм приходят в виде string-ов и массивов
# этот модуль призван помогать конвертировать значения у обычных аксессоров
# тем же способом, что это делает и активрекорд
#
# пока поддерживается только cast_to_boolean
module CastingAccessors
  def cast_to_boolean accessor
    define_method "#{accessor}_with_casting=" do |value|
      casted_value = case value
        when nil
          nil
        when '1', true
          true
        else
          false
        end

      send "#{accessor}_without_casting=", casted_value
    end
    alias_method_chain "#{accessor}=", :casting
  end
end

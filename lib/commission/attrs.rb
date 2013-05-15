# encoding: utf-8
#
# создает в классе акссессоры, автоматически конвертирующие
# значение в Commission::Formula
module Commission::Attrs
  def has_commission_attrs *attrs
    commission_attrs = attrs.every.to_sym
    commission_attrs.each do |attr|
      attr_reader attr
      define_method "#{attr}=" do |value|
        value = Commission::Formula.new(value) unless value.is_a?(Commission::Formula)
        instance_variable_set "@#{attr}", value
      end
    end
  end
end

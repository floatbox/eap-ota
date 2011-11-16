# encoding: utf-8
class Commission
  module Columns
    extend ActiveSupport::Concern

    def has_commission_columns *columns
      commission_columns = columns.every.to_sym

      commission_columns.each do |column|
        composed_of column,
          :class_name => 'Commission::Formula',
          :mapping => [column, :formula],
          :converter => lambda {|val| Commission::Formula.new(val) },
          :allow_nil => false

      end
      # FIXME UGLY. сделать CommissionValidator < ActiveModel::EachValidator
      validates_each commission_columns, :allow_blank => true do |model, attr, fx|
        model.errors.add(attr, ", некорректное значение: '#{fx}', попробуйте что-то типа '2%', '100.53', '12 eur'") unless fx.valid?
      end
    end

    # тоже вынести в какой-то валидатор
    def has_percentage_only_commissions *columns
      validates_each columns, :allow_blank => true do |model, attr, fx|
        model.errors.add(attr, ", некорректное значение: '#{fx}', попробуйте '#{fx.rate}%'") unless fx.percentage? || fx.zero?
      end
    end

  end
end

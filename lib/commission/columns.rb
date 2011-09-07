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
          :allow_nil => true

        # FIXME UGLY. сделать CommissionValidator < ActiveModel::EachValidator
        validates_each column, :allow_blank => true do |model, attr, value|
          model.errors.add(attr, "invalid commission formula: '#{value}'") unless value.valid?
        end
      end
    end

  end
end

# encoding: utf-8
#
# Делегирует всякую статистику и поиски в default_book класса.
# Нужен для совместимости со старым кодом, использующим Commission.*
module Commission::DefaultBook

  extend ActiveSupport::Concern

  included do
    cattr_accessor :default_book
    self.default_book = Commission::Book.new
  end

  include Commission::Reader

  module ClassMethods
    delegate :commissions, to: :default_book
    delegate :register, to: :default_book

    # FIXME обратная совместимость с текущим использованием Commission.* в админке.
    # TODO Перенести куда-нибудь в Commission::ClassMethods
    delegate :all_for,
             :exists_for?,
             :for_carrier,
             :all,
             :all_carriers,
             :stats,
                to: :default_book

    delegate :find_for,
             :all_with_reasons_for,
                to: :default_book
  end
end

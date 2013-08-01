# encoding: utf-8
class Airplane < ActiveRecord::Base
  extend CodeStash

  scope :autosaved, -> { where(auto_save: true) }

  class << self
    def fetch_by_code(code)
      find_by_iata(code)  # || find_by_iata_ru(code)
    end

    def make_by_code(code)
      Airplane.autosaved.create(iata: code)
    end
  end

  def codes
    [iata, iata_ru]
  end

  has_paper_trail

  def self.engine_types
    { 'Реактивный' => 'jet','Турбовинтовой' => 'prop', 'Поезд' => 'train', 'Автобус' => 'bus', 'Вертолет' => 'heli' }
  end

  validates_inclusion_of :engine_type, :in => engine_types.values


  def name
    name_ru.presence || name_en.presence || iata
  end

  def inspect
    "#<#{self.class}:#{id||new}:(#{iata})>"
  end
end

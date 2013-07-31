# encoding: utf-8
class Airplane < ActiveRecord::Base
  extend CodeStash

  def self.fetch_by_code(code)
    find_by_iata(code)  # || find_by_iata_ru(code)
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

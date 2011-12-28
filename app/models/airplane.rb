# encoding: utf-8
class Airplane < ActiveRecord::Base
  extend IataStash

  has_paper_trail

  def self.engine_types
    { 'Реактивный' => 'jet','Турбовинтовой' => 'prop', 'Поезд' => 'train', 'Автобус' => 'bus' }
  end

  validates_inclusion_of :engine_type, :in => engine_types.values


  def name
    name_ru.presence || name_en.presence || iata
  end
end

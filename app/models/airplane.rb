# encoding: utf-8
class Airplane < ActiveRecord::Base
  extend IataStash

  ENGINE_TYPE = { 'Реактивный' => 'jet','Турбовинтовой' => 'prop', 'Поезд' => 'train', 'Автобус' => 'bus' }

  validates_inclusion_of :engine_type, :in => ENGINE_TYPE.values


  def name
    name_ru.presence || name_en.presence || iata
  end
end

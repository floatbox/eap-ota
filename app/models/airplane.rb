class Airplane < ActiveRecord::Base
  ENGINE_TYPE = { 'jet' => 'Реактивный', 'prop' => 'Турбовинтовой', 'train' => 'Поезд' }

  validates_inclusion_of :engine_type, :in => ENGINE_TYPE.keys


  def name
    name_ru.presence || name_en.presence || iata
  end
end

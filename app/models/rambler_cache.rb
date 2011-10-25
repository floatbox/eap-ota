class RamblerCache
  # на продакшне хранится в capped collection
  # таблицу надо создавать явно:
  # db.createCollection("rambler_caches", {capped:true, size:200000000})
  # удалять объекты нельзя. обновлять можно только, если не увеличивается размер документа
  # TODO сделать флажок об отправке, заранее сохраненный
  include Mongoid::Document
  include Mongoid::Timestamps
  field :data, :type => Array
  belongs_to :pricer_form
end

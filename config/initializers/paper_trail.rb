# добавляет колонки в таблицу версий
class Version < ActiveRecord::Base
  attr_accessible :action
end

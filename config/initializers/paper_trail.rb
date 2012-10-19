# добавляет колонки в таблицу версий
class Version < ActiveRecord::Base
  attr_accessible :done

  def self.item_types
     ["Order", "Payment", "Ticket"]
  end

  def self.events
    ["update", "create"]
  end

  def self.whodunnits
    TypusUser.pluck(:email).sort
  end

end

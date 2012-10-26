# добавляет колонки в таблицу версий
class Version < ActiveRecord::Base
  attr_accessible :done

  def show_link
    object = item_type.downcase.pluralize
    "<a href='/admin/#{object}/show/#{item_id}'>#{item_type} ##{item_id}</a>".html_safe
  end

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

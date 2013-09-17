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
    DeckUser.pluck(:email).sort
  end

  # костыль, устраняет проблему с методом changeset для записей, содержащих
  # сериализованный Proc в формулах. Который нечем десериализовать. Чтобы убрать его,
  # надо как-то выкусить в object_changes соответствующие строки yml за период
  # 16 Jan 2013 - 2 Feb 2013.
  def object_changes
    oc = super
    oc.gsub( /^.*ruby\/object:Proc.*?\n/, '') if oc
  end

end

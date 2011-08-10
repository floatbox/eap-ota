# encoding: utf-8
class OrderComment < ActiveRecord::Base
  belongs_to :order
  belongs_to :typus_user
  belongs_to :assigned_to, :class_name => "TypusUser"

  STATUS = ["не обработан", "в обработке", "обработан"]
  PRIORITY = ['', 'критично', 'срочно', 'нормально', 'подождет']
end

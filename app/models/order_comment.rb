# encoding: utf-8
class OrderComment < ActiveRecord::Base
  belongs_to :order
  belongs_to :typus_user
  belongs_to :assigned_to, :class_name => "TypusUser"

  STATUS = ["не обработан", "в обработке", "обработан"]
  PRIORITY = {'' => 5, 'критично' => 1, 'срочно' => 2, 'нормально' => 3,  'подождет' => 4}
end

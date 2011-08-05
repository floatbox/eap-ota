# encoding: utf-8
class OrderComment < ActiveRecord::Base
  belongs_to :order
  belongs_to :typus_user
  belongs_to :assigned_to, :class_name => "TypusUser"

  def self.statuses; ["не обработан", "в обработке", "обработан"] end
  def self.priorities; {'' => 5, 'критично' => 1, 'срочно' => 2, 'нормально' => 3,  'подождет' => 4} end
end

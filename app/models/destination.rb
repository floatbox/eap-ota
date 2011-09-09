# encoding: utf-8
class Destination < ActiveRecord::Base
  belongs_to :from, :class_name => "City"
  belongs_to :to, :class_name => "City"
  has_many :hot_offers, :dependent => :destroy

  def self.rts
    { ' → ' => false, ' ⇄ ' => true}
  end

  def name
    "#{from.name} #{Destination.rts.invert[rt]} #{to.name}"
  end

end


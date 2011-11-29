# encoding: utf-8
class Destination < ActiveRecord::Base
  belongs_to :from, :class_name => "City"
  belongs_to :to, :class_name => "City"
  has_many :hot_offers, :dependent => :destroy
  has_many :subscriptions

  def self.rts
    { ' → ' => false, ' ⇄ ' => true}
  end

  def name
    "#{from.name} #{Destination.rts.invert[rt]} #{to.name}"
  end

  def nullify
    hot_offers.delete_all
    update_attributes :average_price => nil, :average_time_delta => nil, :hot_offers_counter => 0
  end

end


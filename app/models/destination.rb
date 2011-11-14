# encoding: utf-8
class Destination
  include Mongoid::Document
  include Mongoid::Timestamps

  extend Typus::Orm::Base

  field :to_id, :type => Integer
  field :from_id, :type => Integer
  field :rt, :type => Boolean
  field :average_price, :type => Integer
  field :average_time_delta, :type => Integer
  field :hot_offers_counter, :type => Integer, :default => 0

  belongs_to :from, :class_name => "City"
  belongs_to :to, :class_name => "City"

  has_many :hot_offers, :dependent => :destroy

  def self.rts
    { ' → ' => false, ' ⇄ ' => true}
  end

  def name
    "#{from.name} #{RT.invert[rt]} #{to.name}"
    end

  def self.table_name
      collection_name
  end

  def self.build_conditions (*)

  end


  ActiveRecord::Base.instance_eval do
    def using_object_ids?
       false
    end
  end

  def nullify
    hot_offers.delete_all
    update_attributes :average_price => nil, :average_time_delta => nil, :hot_offers_counter => 0
  end

end


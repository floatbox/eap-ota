# encoding: utf-8
class Destination
  include Mongoid::Document
  include Mongoid::Timestamps

  extend Typus::Orm::Base

  field :to_iata, :type => String
  field :from_iata, :type => String
  field :rt, :type => Boolean
  field :average_price, :type => Integer
  field :average_time_delta, :type => Integer
  field :hot_offers_counter, :type => Integer, :default => 0


  has_many :hot_offers, :dependent => :destroy

  def self.rts
    { ' → ' => false, ' ⇄ ' => true}
  end

  def name
    "#{from.name} #{Destination.rts.invert[rt]} #{to.name}"
  end

  def from
    City.find_by_iata from_iata
  end

  def to
    City.find_by_iata to_iata
  end

  def self.table_name
      collection_name
  end

  def self.build_conditions (*)

  end

  def nullify
    hot_offers.delete_all
    update_attributes :average_price => nil, :average_time_delta => nil, :hot_offers_counter => 0
  end

end


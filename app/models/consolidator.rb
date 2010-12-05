class Consolidator < ActiveRecord::Base
  has_many :airlines, :foreign_key => :consolidator_id
end
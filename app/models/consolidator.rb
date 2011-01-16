# encoding: utf-8
class Consolidator < ActiveRecord::Base
  has_many :carriers, :foreign_key => :consolidator_id
end

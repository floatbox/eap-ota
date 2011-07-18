# encoding: utf-8
class OrderComment < ActiveRecord::Base
  belongs_to :order
  belongs_to :typus_user
  
end
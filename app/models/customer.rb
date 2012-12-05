# encoding: utf-8
class Customer < ActiveRecord::Base

  has_paper_trail

  has_many :orders

end

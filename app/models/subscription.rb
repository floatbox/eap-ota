# encoding: utf-8
class Subscription < ActiveRecord::Base
  belongs_to :destination

end
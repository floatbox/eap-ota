# encoding: utf-8
class GlobalDistributionSystem < ActiveRecord::Base
  has_many :carriers, :foreign_key => 'gds_id'
end

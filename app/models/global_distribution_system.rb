class GlobalDistributionSystem < ActiveRecord::Base
  has_many :airlines, :foreign_key => 'gds_id'
end
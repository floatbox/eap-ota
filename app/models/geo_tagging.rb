# encoding: utf-8
class GeoTagging < ActiveRecord::Base
  belongs_to :geo_tag
  belongs_to :location, :polymorphic => true
end

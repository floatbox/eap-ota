class Destination < ActiveRecord::Base
  belongs_to :from, :class_name => "City"
  belongs_to :to, :class_name => "City"
  has_many :hot_offers, :dependent => :destroy

  RT = { ' → ' => false, ' ⇄ ' => true}

  def name
    "#{from.name} #{RT.invert[rt]} #{to.name}"
  end

  def calculate_avg_values
    if hot_offers.present?
      self.average_price = hot_offers.every.price.sum / hot_offers.count
      self.average_time_delta = hot_offers.every.time_delta.sum / hot_offers.count
    end
  end
end


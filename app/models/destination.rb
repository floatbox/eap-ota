class Destination < ActiveRecord::Base
  belongs_to :from, :class_name => "City"
  belongs_to :to, :class_name => "City"
  has_many :hot_offers, :dependent => :destroy

  RT = { ' → ' => false, ' ⇄ ' => true}

  def name
    "#{from.name} #{RT.invert[rt]} #{to.name}"
  end

end


class Recommendation

  attr_accessor :id, :prices, :variants, :price_total, :additional_info

  def initialize keys={}
    self.id = object_id
    keys.each do |attr, value|
      send "#{attr}=", value
    end
  end

end

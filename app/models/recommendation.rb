class Recommendation

  attr_accessor :id, :prices, :variants, :price_total, :additional_info

  def initialize keys={}
    self.id = object_id
    keys.each do |attr, value|
      send "#{attr}=", value
    end
  end

  def sellable?
    variants.every.segments.flatten.every.marketing_carrier.all? &:aviacentr
  end

  def bullshit?
    variants.every.segments.flatten.every.flights.flatten.any? {|f| f.equipment_type.engine_type == 'train' }
  end
end

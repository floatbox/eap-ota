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

  def minimal_duration
    variants.map(&:total_duration).min
  end

  def self.cheap recs
    recs.select(&:sellable?).min_by(&:price_total)
  end

  def self.fast recs
    recs.select(&:sellable?).min_by(&:minimal_duration)
  end

  def variants_by_duration
    variants.sort(&:total_duration)
  end
  
  def self.summary recs
    airlines = []
    planes = []
    departure_airport_groups = []
    arrival_airport_groups = []
    recs.each {|r|
      r.variants.each{|v|
        summary = v.summary
        airlines += summary[:airlines]
        planes += summary[:planes]
        if departure_airport_groups == []
          departure_airport_groups = summary[:departure_airports].map{|a| [a]}
        else
          summary[:departure_airports].each_with_index{|airport, i| departure_airport_groups[i] << airport }
        end
        if arrival_airport_groups == []
          arrival_airport_groups = summary[:arrival_airports].map{|a| [a]}
        else
          summary[:arrival_airports].each_with_index{|airport, i| arrival_airport_groups[i] << airport }
        end
      }
    }
    { :airlines => airlines.uniq.map{|a| {'v' => a, 't' => Airline[a].name}},
      :arrival_airport_groups => arrival_airport_groups.map{|g| g.uniq.map{|airport| {'v' => airport, 't' => Airport[airport].name}}},
      :departure_airport_groups => departure_airport_groups.map{|g| g.uniq.map{|airport| {'v' => airport, 't' => Airport[airport].name}}}
    }
  end
end

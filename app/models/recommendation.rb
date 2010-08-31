class Recommendation

  attr_accessor :prices, :variants, :price_total, :additional_info

  def initialize keys={}
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
    variants.sort_by(&:total_duration)
  end

  # comparison, uniquiness, etc.
  def signature
    [price_total, variants]
  end

  def hash
    signature.hash
  end

  def eql?(b)
    signature.eql?(b.signature)
  end

  # FIXME порнография какая-то. чего так сложно?
  def self.summary recs
    airlines = []
    planes = []
    departure_airports = []
    arrival_airports = []
    departure_times = []
    arrival_times = []
    segments_amount = recs[0].variants[0].segments.length
    segments_amount.times {|i|
      departure_airports[i] = []
      arrival_airports[i] = []
      departure_times[i] = []
      arrival_times[i] = []
    }
    recs.each {|r|
      r.variants.each{|v|
        summary = v.summary
        airlines += summary[:airlines]
        planes += summary[:planes]
        v.segments.length.times {|i|
          departure_airports[i] << summary['dpt_airport_' + i.to_s]
          arrival_airports[i] << summary['arv_airport_' + i.to_s]
          departure_times[i] << summary['dpt_time_' + i.to_s]
          arrival_times[i] << summary['arv_time_' + i.to_s]
        }
      }
    }
    result = {
      :airlines => airlines.uniq.map{|a| {:v => a, :t => Airline[a].name}}.sort_by{|a| a[:t] },
      :planes => planes.uniq.map{|a| {:v => a, :t => Airplane[a].name}}.sort_by{|a| a[:t] },
      :segments => segments_amount
    }
    departure_airports.each_with_index {|airports, i|
      result['dpt_airport_' + i.to_s] = airports.uniq.map{|airport| {:v => airport, :t => Airport[airport].name} }.sort_by{|a| a[:t] }
    }
    arrival_airports.each_with_index {|airports, i|
      result['arv_airport_' + i.to_s] = airports.uniq.map{|airport| {:v => airport, :t => Airport[airport].name} }.sort_by{|a| a[:t] }
    }
    time_titles = ['ночь', 'утро', 'день', 'вечер']
    departure_times.each_with_index {|dpt_times, i|
      result['dpt_time_' + i.to_s] = dpt_times.uniq.sort.map{|dt| {:v => dt, :t => time_titles[dt]} }
    }
    arrival_times.each_with_index {|arv_times, i|
      result['arv_time_' + i.to_s] = arv_times.uniq.sort.map{|at| {:v => at, :t => time_titles[at]} }
    }
    result
  end
end

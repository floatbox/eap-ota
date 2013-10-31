class FareRule < ActiveRecord::Base
  belongs_to :order

  def as_json( options={} )
    super({only: [:from_iata, :to_iata, :fare_base, :carrier, :rule_text, :passenger_type]})
  end

  def to
    Location[to_iata]
  end

  def from
    Location[from_iata]
  end

end

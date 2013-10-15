class FareRule < ActiveRecord::Base
  belongs_to :order

  def to
    Location[to_iata]
  end

  def from
    Location[from_iata]
  end

end

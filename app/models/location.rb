# encoding: utf-8
class Location

  def self.default
    # москва
    City['MOW']
  end

  def self.[](iata)
    City[iata]
  rescue IataStash::NotFound
    Airport[iata]
  end

end


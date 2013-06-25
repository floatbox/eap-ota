# encoding: utf-8
require 'httparty'

class Tripster

  cattr_accessor :logger do
    Rails.logger
  end

  def self.load_cities
    response = HTTParty.get("http://experience.tripster.ru/partner/v1/cities_iata")
    MongoStorage.write('cities', response.split, :namespace => 'tripster')
    logger.info 'Tripster: load cities list at ' + Time.now.to_s
  end

end
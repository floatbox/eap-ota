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

  # naive geolocation
  def self.nearest_city(ip)
    return Location.default unless Conf.geolocation.enabled
    begin
      Timeout.timeout(1) do
        loc = GeoIp.geolocation(ip)
        if loc[:latitude] == "0" && loc[:longitude] == "0" ||
          loc[:latitude] == "60" && loc[:longitude] == "100"
          return Location.default
        end
        return City.nearest_to loc[:latitude], loc[:longitude]
      end
    # для оффлайна
    rescue Errno::EHOSTUNREACH, SocketError, JSON::ParserError, Timeout::Error, RestClient::Exception
      Location.default
    end
  end

end

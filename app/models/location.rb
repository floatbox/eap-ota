# encoding: utf-8
class Location

  def self.default
    # москва
    City['MOW']
  end

  def self.[](iata)
    City[iata]
  rescue CodeStash::NotFound
    Airport[iata]
  end

  # naive geolocation
  # FIXME обернуть счетчиками. А то даже не заметим, когда нас отключат от геолокации.
  def self.nearest_city(ip)
    return Location.default unless Conf.geolocation.enabled
    begin
      loc = Timeout.timeout(1) do
        Rails.logger.info "geolocating IP #{ip}"
        GeoIp.geolocation(ip)
      end
      if loc[:latitude] == "0" && loc[:longitude] == "0" ||
        loc[:latitude] == "60" && loc[:longitude] == "100"
        return Location.default
      end
      return City.nearest_to(loc[:latitude], loc[:longitude]).first || Location.default
    # для оффлайна
    rescue Errno::EHOSTUNREACH, SocketError, JSON::ParserError, Timeout::Error, RestClient::Exception
      Rails.logger.warn "geolocation error: #{$!}"
      Location.default
    end
  end

end

class HomeController < ApplicationController
  def index
  end

  def geo
    loc = GeoIp.geolocation(request.remote_ip)
    render :text => "ip #{request.ip}, remote_ip: #{request.remote_ip}, nearest_city: #{nearest_city.name} loc: #{loc[:latitude]} #{loc[:longitude]} #{loc[:city]}"
  end

  protected

  # naive geolocation
  def nearest_city
    @nearest_city ||= begin
      loc = GeoIp.geolocation(request.remote_ip)
      if loc[:country_name] == 'Reserved'
        return Location.default
      end
      City.nearest_to loc[:latitude], loc[:longitude]
    # для оффлайна
    rescue Errno::EHOSTUNREACH, SocketError, JSON::ParserError
      Location.default
    end
  end
  helper_method :nearest_city

end

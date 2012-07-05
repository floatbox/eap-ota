# encoding: utf-8
class HomeController < ApplicationController
  def index
  end

  def whereami
    loc = GeoIp.geolocation(request.remote_ip)
    render :json => {:city_name => nearest_city.name, :lat => loc[:latitude], :lng => loc[:longitude]}
  end

  protected

  # naive geolocation
  def nearest_city
    return Location.default unless Conf.geolocation.enabled
    @nearest_city ||= begin
      Timeout.timeout(1) do
        loc = GeoIp.geolocation(request.remote_ip)
        if loc[:latitude] == "0" && loc[:longitude] == "0" ||
          loc[:latitude] == "60" && loc[:longitude] == "100"
          return Location.default
        end
        City.nearest_to loc[:latitude], loc[:longitude]
      end
    # для оффлайна
    rescue Errno::EHOSTUNREACH, SocketError, JSON::ParserError, Timeout::Error, RestClient::Exception
      Location.default
    end
  end
  helper_method :nearest_city

end


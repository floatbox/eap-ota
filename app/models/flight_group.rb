class FlightGroup < ActiveRecord::Base
  include Rails.application.routes.url_helpers

  #для тайпуса
  def url
    url = show_flight_group_path(self)
    "<a href=#{url}>Ссылка</a>".html_safe
  end
end

# encoding: utf-8
module ProfileOrder

  extend ActiveSupport::Concern

  included do
    scope :profile_orders, where("pnr_number != ''").order("created_at DESC")
  end

  def profile_route
    airports = []
    route_string = route.blank? ? tickets.first.route : route
    route_string.split(';').map{|s| s.split(' - ')}.flatten.map{|s| s.strip.split.first}.each{|s| airports << s if airports.last != s }
    cities = airports.map{|a| Airport.find_by_iata(a).city.name}
    cities.join(' → ')
  end

  def profile_status
    payment_status + "\n" + ticket_status
  end

  def profile_tickets
    rows = []
    if ticketed?
      tickets.each do |t|
        rows << {
          name: t.last_name + ' ' + t.first_name,
          status: t.status,
          number: t.number,
          carrier: t.carrier
        }
      end
    else
      infos = full_info.split
      infos.each do |t|
        data = t.split('/')
        rows << {
          name: data[1] + ' ' + data[0]
        }
      end
    end
    rows
  end

  def ticketed?
    tickets_count > 0
  end

end

# encoding: utf-8
module ProfileOrder
  include Rails.application.routes.url_helpers

  extend ActiveSupport::Concern

  included do
    scope :profile_orders, where("pnr_number != ''").order("created_at DESC")
  end

  def can_use? current_customer
    current_customer.id == customer.id
  end

  def profile_route
    route.blank? ? tickets.first.route.gsub(/ \([A-Z]{2}\)/, '') : route
  end

  def profile_route_smart
    route_string = profile_route
    rt = route_string.split(';').size.even?
    airports = []
    cities = []
    route_flights = route_string.gsub(/([A-Z]{3}); \1/, '\1').split('; ').map{|s| s.split(' - ')}
    if rt && route_flights.size == 1 && route_flights.first == route_flights.first.reverse
      rt_flight = [ route_flights.first.first, route_flights.first[route_flights.first.size / 2] ]
      rt_flight.each do |iata|
        cities << Airport[iata].city.name
      end
      cities.join(' ⇄  ')
    else
      route_flights.each do |fl|
        cities << fl.map{|iata| Airport[iata].city.name}.join(' → ')
      end
      cities.join(', ')
    end
  end

  def profile_route_decorated
    airports = []
    profile_route.split('; ').map{|s| s.split(' - ')}.flatten.map{|s| s.strip.split.first}.each{|s| airports << s if airports.last != s }
    cities = airports.map{|iata| Airport[iata].city.name}
    cities.join(' → ')
  end

  def profile_status
    payment_status + "\n" + ticket_status
  end

  def profile_payment_price
    if payments.charges.secured.first
      payments.charges.secured.first.price.round.to_i
    else
      price_with_payment_commission.round.to_i
    end
  end

  def profile_tickets
    rows = []
    if profile_ticketed?
      tickets.each do |t|
        rows << {
          id: t.id,
          name: t.last_name + ' ' + t.first_name,
          status: t.status,
          number: t.number,
          carrier: t.carrier,
          stored_flight: t.flights.present?
        }
      end
    else
      infos = full_info.split("\n")
      infos.each do |t|
        data = t.split('/')
        rows << {
          name: data[1] + ' ' + data[0]
        }
      end
    end
    rows
  end

  def profile_ticketed?
    tickets_count > 0
  end

end

# encoding: utf-8
module ProfileOrder
  include Rails.application.routes.url_helpers

  extend ActiveSupport::Concern

  included do
    scope :profile_orders, where("pnr_number != ''").where(:ticket_status => ['booked', 'ticketed']).order("created_at DESC")
  end

  def can_use? current_customer
    current_customer.id == customer.id
  end

  def profile_route
    route.blank? ? tickets.first.route.gsub(/ \([A-Z0-9]{2}\)/, '') : route
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
    # FIXME некрасиво, переписать надо
    return 'денежные средства заблокированы на карте' if payment_type == 'card' && payment_status == 'blocked'
    return 'денежные средства списаны с карты' if payment_type == 'card' && payment_status == 'charged'
    return 'оплачен' if ['cash','invoice'].include?(payment_type) && payment_status == 'charged'
    return 'оплачен' if payment_type == 'card' && ticket_status == 'ticketed'
    return 'ожидает оплаты' if payment_status == 'pending'
    return 'ожидает оплаты'
  end

  def profile_payment_price
    if payments.charges.secured.first
      payments.charges.secured.first.price.round.to_i
    else
      price_with_payment_commission.round.to_i
    end
  end

  def profile_people
    full_info.split("\n").collect do |t|
      data = t.split('/')
      {
        name: data[1] + ' ' + data[0],
        status: ['blocked','charged'].include?(payment_status) ? 'оформляется' : 'забронирован' 
      }
    end
  end

  def profile_flights
    sold_tickets.first.flights.presence
  end

  def profile_booking_classes
    sold_tickets.first.booking_classes
  end

  def profile_ticketed?
    tickets_count > 0
  end

  def profile_sold_tickets_count
    sold_tickets.count
  end

  def profile_stored?
    tickets_count > 0 && tickets.first.flights.present?
  end

  def profile_tickets
    parents = profile_ticket_parents
    if parents
      tickets.where(:kind=>'ticket').where('status <> "exchanged" OR id NOT IN ' + parents)
    else
     tickets.where(:kind=>'ticket')
    end
  end

  def profile_ticket_parents
    ids = tickets.pluck(:parent_id).compact
    !ids.empty? ? '(' + ids.compact.join(',') + ')' : nil
  end

  def profile_arrival_date
    profile_flights.last.arrv_date if profile_flights.present?
  end

  def profile_arrival_in_future?
    profile_arrival_date && profile_arrival_date > DateTime.now
  end

  def profile_alive_tickets_exists?
    profile_tickets.each do |t|
      return true if t.profile_alive?
    end
    return false
  end

  def profile_all_tickets_returned?
    profile_tickets.each do |t|
      return false unless t.profile_returned?
    end
    return true
  end

end
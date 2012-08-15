# encoding: utf-8
class SeatMapController < ApplicationController

  def show
    flight = Flight.from_flight_code params[:flight]
    booking_class = params[:booking_class]
    seat_map_resp = availability_resp = nil
    Amadeus.booking do |amadeus|
      seat_map_resp = amadeus.air_retrieve_seat_map(:flight => flight, :booking_class => booking_class)
      availability_resp = amadeus.air_multi_availability(:flight => flight)
    end
    @seat_map = seat_map_resp.seat_map if seat_map_resp.success?
    @availability_summary = availability_resp.availability_summary
    render 'seat_map'
  end

  private

  helper_method :debug_chars
  def debug_chars(type, object)
    object.characteristics.keys.collect { |prop|
      "<a href='##{type}_#{prop}'>#{prop}</a>"
    }.join(' ').html_safe
  end

end

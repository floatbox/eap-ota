# encoding: utf-8
class SeatMapController < ApplicationController

  def show
    flight = Flight.from_flight_code params[:flight]
    booking_class = params[:booking_class]
    resp = Amadeus.booking{|amadeus| amadeus.air_retrieve_seat_map(:flight => flight, :booking_class => booking_class)}
    if resp.success?
      @seat_map = resp.seat_map
      render 'seat_map'
    else
      render :text => 'Sorry, no seat map available'
    end
  end

  private

  helper_method :debug_chars
  def debug_chars(type, object)
    object.characteristics.keys.collect { |prop|
      "<a href='##{type}_#{prop}'>#{prop}</a>"
    }.join(' ').html_safe
  end

end

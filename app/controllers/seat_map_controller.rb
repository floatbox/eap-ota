# encoding: utf-8
class SeatMapController < ApplicationController
  helper_method :view_hash
  def show
    amadeus = Amadeus.booking
    flight = Flight.from_flight_code params[:flight]
    if flight.is_a? Flight
      resp = amadeus.air_retrieve_seat_map(:flight => flight)
    end
    amadeus.release
    if resp && resp.success?
      @seat_map = resp
      render 'seat_map'
    else
      render :text => 'Sorry, no seat map available'
    end
  end
  
  def view_hash
    view_hash = {}
    @seat_map.segments.each do |segment|
    segment.rows.each do |number, row|
      view_hash[number] =
        row.seats.values.map do |seat|
           seat_string = ''
           availability = seat.available? ? ' :F' : ' :O'
           case
           when seat.window?
            seat_string += seat.column_name + availability + ' :Window' + ' '
           when seat.aisle?
            seat_string += seat.column_name + availability + ' :Aisle' + ' '
           when seat.center?
            seat_string += seat.column_name + availability + ' :Center' + ' '
           else
            seat_string += seat.column_name + availability  + ' :Unknown' + ' '
           end
        end
      end
    end
    view_hash
  end
end
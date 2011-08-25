# encoding: utf-8
class FlightGroupsController < ApplicationController

  layout 'pnr'

  def show
    fg = FlightGroup.find(params[:id])
    @flights = fg.code.split("\n").map{|fc| Flight.from_amadeus_code(fc) || Flight.from_short_code(fc)}.compact
  end
end


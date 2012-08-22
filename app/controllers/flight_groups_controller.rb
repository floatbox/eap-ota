# encoding: utf-8
class FlightGroupsController < ApplicationController

  layout 'pnr'

  def show
    fg = FlightGroup.find(params[:id])
    @flights = fg.code.split("\n").map{|fc| Flight.from_gds_code(fc, fg.source)}.compact
    @prices = Order.new
  end
end


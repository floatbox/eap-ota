# encoding: utf-8
class Admin::StoredFlightsController < Admin::EviterraResourceController
  def update_from_gds
    @stored_flight = StoredFlight.find(params[:id])
    @stored_flight.update_from_gds!
    redirect_to :action => :show, :id => @stored_flight.id
  end
end

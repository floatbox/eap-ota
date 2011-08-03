# encoding: utf-8
class PNRController < ApplicationController

  rescue_from RuntimeError, :with => :error
  before_filter :get_pnr, :only => [:show, :show_as_booked, :show_as_ticketed]

  def get_pnr
    @pnr = Pnr.get_by_number params[:id]
  end

  def show_as_booked
    @pnr.order.itinerary_receipt_view = 'booked'
    render :action => "show"
  end

  def show_as_ticketed
    @pnr.order.itinerary_receipt_view = 'ticketed'
    render :action => "show"
  end

  def error
    render 'error'
  end

  # sirena pdf receipt FIXME unfinished, unused
  def receipt
    @pnr = Pnr.get_by_number params[:id]
    if @pnr.order && @pnr.order.source == 'sirena'
      render :text => @pnr.sirena_receipt, :content_type => 'application/pdf'
    end
  end
end


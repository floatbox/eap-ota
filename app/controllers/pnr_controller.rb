# encoding: utf-8
class PNRController < ApplicationController

  rescue_from RuntimeError, :with => :error
  before_filter :get_pnr, :only => [:show, :show_as_booked, :show_as_ticketed, :show_for_ticket]

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

  def show_for_ticket
    ticket = Ticket.find(params[:ticket_id])
    raise 'ticket don\'t belong to order' if ticket.order != @pnr.order
    k = (ticket.price_tax + ticket.price_fare).to_f / (ticket.order.price_fare + ticket.order.price_tax)
    @pnr.order.price_with_payment_commission *= k
    @pnr.order.price_fare = ticket.price_fare
    @pnr.passengers = [Person.new(:first_name => ticket.first_name, :last_name => ticket.last_name, :passport => ticket.passport, :ticket => ticket.number)]
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


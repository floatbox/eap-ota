# encoding: utf-8
class PNRController < ApplicationController

  rescue_from RuntimeError, :with => :error
  before_filter :set_lang
  before_filter :get_data, :only => [:show, :show_as_booked, :show_as_order, :show_as_ticketed, :show_notice]

  def set_lang
    @lang = params[:lang]
  end

  def get_data
    @pnr = PNR.get_by_number params[:id]
    @prices = @pnr.order
    @passengers = @pnr.passengers
    @last_pay_time = @pnr.order.last_pay_time
  end

  def show
    if @pnr.order.show_as_ticketed?
      render "ticket"
    else
      render "booking"
    end
  end

  def show_notice
      format = params[:format] ? params[:format] : @pnr.order.send_notice_as
      render format
  end

  def show_stored
    order = Order[params[:id]] or raise ActiveRecord::RecordNotFound
    tickets = order.sold_tickets
    ticket = tickets.first
    @last_pay_time = order.last_pay_time
    @pnr = PNR.new(:email => order.email, :phone => order.phone, :number => order.pnr_number, :booking_classes => ticket.booking_classes)
    @flights = ticket.flights.presence

    @prices = order
    @passengers = tickets.map do |t|
      Person.new(:first_name => t.first_name, :last_name => t.last_name, :passport => t.passport, :tickets => [t])
    end

    get_data unless @flights
    render "ticket"
  end

  def show_as_booked
    render "booking"
  end

  def show_as_order
    render "order"
  end

  def show_as_ticketed
    render "ticket"
  end

  def show_for_ticket
    order = Order[params[:id]] or raise ActiveRecord::RecordNotFound
    ticket = order.tickets.find(params[:ticket_id])
    @last_pay_time = order.last_pay_time
    @pnr = PNR.new(:email => order.email, :phone => order.phone, :number => order.pnr_number, :booking_classes => ticket.booking_classes)
    @flights = ticket.flights.presence

    get_data unless @flights

    @prices = ticket
    @passengers = [Person.new(:first_name => ticket.first_name, :last_name => ticket.last_name, :passport => ticket.passport, :tickets => [ticket])]
    render "ticket"
  end

  def error
    with_warning
    render 'error', :status => 500
  end

end


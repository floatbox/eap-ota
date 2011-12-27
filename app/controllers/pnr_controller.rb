# encoding: utf-8
class PNRController < ApplicationController

  rescue_from RuntimeError, :with => :error
  before_filter :get_data, :only => [:show, :show_as_booked, :show_as_ticketed, :show_for_ticket]

  def get_data
    @pnr = PNR.get_by_number params[:id]
    @prices = @pnr.order
    @pnr.email = @prices.email if @prices.source == 'sirena' && @pnr.email.blank?
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

  def show_as_booked
    render "booking"
  end

  def show_as_ticketed
    render "ticket"
  end

  def show_for_ticket
    ticket = Ticket.find(params[:ticket_id])
    raise 'ticket don\'t belong to order' if ticket.order != @pnr.order
    @prices = ticket
    @passengers = [Person.new(:first_name => ticket.first_name, :last_name => ticket.last_name, :passport => ticket.passport, :tickets => [ticket])]
    render "ticket"
  end

  def show_sent_notice
    notice = Notification.find(params[:id])
    render :text => notice.rendered_message
  end

  def error
    Airbrake.notify($!) rescue Rails.logger.error("  can't notify airbrake #{$!.class}: #{$!.message}")
    render 'error', :status => 500
  end

  # sirena pdf receipt FIXME unfinished, unused
  def receipt
    @pnr = PNR.get_by_number params[:id]
    if @pnr.order && @pnr.order.source == 'sirena'
      render :text => @pnr.sirena_receipt, :content_type => 'application/pdf'
    end
  end
end


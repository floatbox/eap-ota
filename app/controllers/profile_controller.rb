class ProfileController < ApplicationController

  before_filter :authenticate_customer!
  before_filter :check_order_permission, :only => [:show_pnr]


  def index
    @orders = current_customer.orders.profile_orders
  end

  def show_pnr
    if !@order.profile_ticketed?
      if !@order.notifications.first_sent_order_pnr.empty?
        notice = @order.notifications.first_sent_order_pnr.first
        render :text => notice.rendered_message
      else
        redirect_to show_notice_path(:id => @order.pnr_number)
      end
    else
      if !@order.notifications.last_sent_ticket_pnr.empty?
        notice = @order.notifications.last_sent_ticket_pnr.first
        render :text => notice.rendered_message
      else
        redirect_to show_notice_path(:id => @order.pnr_number)
      end
    end
  end

  def show_stored_pnr
    if @order.profile_stored?
        redirect_to show_order_stored_path(:id => @order.pnr_number)
    end
  end

  def show_pnr_for_ticket
    order = Order[params[:id]] or raise ActiveRecord::RecordNotFound
    ticket = order.tickets.find(params[:ticket_id])
    @lang = params[:lang]
    @last_pay_time = order.last_pay_time
    @pnr = PNR.new(:email => order.email, :phone => order.phone, :number => order.pnr_number, :booking_classes => ticket.booking_classes)
    @flights = ticket.flights.presence

    @prices = ticket
    @passengers = [Person.new(:first_name => ticket.first_name, :last_name => ticket.last_name, :passport => ticket.passport, :tickets => [ticket])]
    render "pnr/ticket", :layout => 'pnr'
  end

  def check_order_permission
    @order = Order[params[:id]] or raise ActiveRecord::RecordNotFound
    @order.can_use? current_customer
  end

end

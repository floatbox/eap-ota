class ProfileController < ApplicationController

  before_filter :authenticate_customer!, :except=> [:spyglass, :orders]
  before_filter :check_order_permission, :only => [:show_pnr, :itinerary]

  def orders
    if admin_user && params[:current_customer_id]
      current_customer = Customer.find(params[:current_customer_id])
    end
    if current_customer
      @orders = current_customer.orders.profile_orders
      @exchanged_tickets_numbers = current_customer.orders.profile_orders.collect {|o| o.profile_exchanged_tickets_numbers}.flatten || []
      render :partial => 'orders'
    else
      redirect_to :profile
    end
  end

  # FIXME обязательно убрать этот метод при выкладке на прод
  def spyglass
    current_customer = Customer.find(params[:id])
    if admin_user && current_customer
      render :index, :locals => {:current_customer => current_customer}
    else
      redirect_to :profile
    end
  end

  # TODO сделать метод itinerary для показа маршрутки через этот контроллер

  def check_order_permission
    @order = Order[params[:id]] or raise ActiveRecord::RecordNotFound
    @order.can_use? current_customer
  end

end

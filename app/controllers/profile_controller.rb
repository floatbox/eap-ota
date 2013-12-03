class ProfileController < ApplicationController

  before_filter :authenticate_customer!, :except=> [:spyglass, :orders]
  before_filter :check_order_permission, :only => [:show_pnr, :itinerary]

  def orders
    if admin_user && params[:current_customer_id]
      spyglass_customer = Customer.find(params[:current_customer_id])
      @orders = spyglass_customer.orders.profile_orders
    else
      authenticate_customer!
      @orders = current_customer.orders.profile_orders
    end

    @exchanged_tickets_numbers = @orders.collect {|o| o.profile_exchanged_tickets_numbers}.flatten || []
    render :partial => 'orders'
  end

  # FIXME обязательно убрать этот метод при выкладке на прод
  def spyglass
    spyglass_customer = Customer.find(params[:id])
    if admin_user && spyglass_customer
      render :index, :locals => {:current_customer => spyglass_customer}
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

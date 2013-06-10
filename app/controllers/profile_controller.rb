class ProfileController < ApplicationController

  before_filter :authenticate_customer!, :except=> [:spyglass]
  before_filter :check_order_permission, :only => [:show_pnr, :itinerary]

  def index
    @orders = current_customer.orders.profile_orders
  end

  # FIXME обязательно убрать этот метод при выкладке на прод
  def spyglass
    if admin_user
      current_customer = Customer.find(params[:id])
      @orders = current_customer.orders.profile_orders
      render :index, :locals => {:current_customer => current_customer}
    else
      redirect_to :profile
    end
  end

  def check_order_permission
    @order = Order[params[:id]] or raise ActiveRecord::RecordNotFound
    @order.can_use? current_customer
  end

end

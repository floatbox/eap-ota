class ProfileController < ApplicationController

  before_filter :authenticate_customer!
  before_filter :check_order_permission, :only => [:show_pnr]

  def index
    @orders = current_customer.orders.profile_orders
  end

  def check_order_permission
    @order = Order[params[:id]] or raise ActiveRecord::RecordNotFound
    @order.can_use? current_customer
  end

end

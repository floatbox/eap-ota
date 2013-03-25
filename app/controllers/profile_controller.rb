class ProfileController < ApplicationController

  before_filter :authenticate_customer!

  def index
    @orders = current_customer.orders.profile_orders
  end

end

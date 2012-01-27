# encoding: utf-8
class ApiOrderStatController < ApplicationController
  USER_ID, PASSWORD = "yandex", "admin"
  before_filter :authenticate

  def index
    orders = Order.where(:created_at=>Date.parse(params[:start_date])..Date.parse(params[:end_date]), :partner => USER_ID)
    order_to_send = {}
    orders_to_send = []
    orders.each do |order|
      order_to_send[:marker] = order.marker
      order_to_send[:price] = order.price_with_payment_commission
      order_to_send[:income] = order.income
      order_to_send[:created_at] = order.created_at
      order_to_send[:route] = order.route
      order_to_send[:partner] = order.partner #для теста!!! убрать
      orders_to_send << order_to_send
    end
    orders_to_send = orders_to_send.to_json
    render :json => orders_to_send
  end

  private
    def authenticate
      authenticate_or_request_with_http_basic do |id, password|
        id == USER_ID && password == PASSWORD
    end
   end
end
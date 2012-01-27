# encoding: utf-8
class ApiOrderStatController < ApplicationController
  USER_ID, PASSWORD = "yandex", "admin"
  before_filter :authenticate

  def index
    orders = Order.where(:created_at=>Date.parse(params[:start_date])..Date.parse(params[:end_date]), :partner => USER_ID)
    orders_to_send = {}
    orders.each do |order|
      orders_to_send[:marker] = order.marker
      orders_to_send[:price] = order.price_with_payment_commission
      orders_to_send[:income] = order.income
      orders_to_send[:created_at] = order.created_at
      orders_to_send[:route] = order.route
      orders_to_send[:partner] = order.partner #для теста!!! убрать
      orders_to_send = orders_to_send.to_json
    end
    render :json => orders_to_send
  end

  private
    def authenticate
      authenticate_or_request_with_http_basic do |id, password|
        id == USER_ID && password == PASSWORD
    end
   end
end
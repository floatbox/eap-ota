# encoding: utf-8
class ApiOrderStatController < ApplicationController
  before_filter :authenticate

  def index
    orders = Order.where(:created_at=>Date.parse(params[:date_start])..Date.parse(params[:date_end]), :partner => @id)
    orders_to_send = orders.map do |order|
      {
      :marker => order.marker,
      :price => order.price_with_payment_commission,
      :income => order.income,
      :created_at => order.created_at,
      :route => order.route
      }
    end
    render :json => orders_to_send.to_json
  end

  private
    def authenticate
      authenticate_or_request_with_http_basic do |id, password|
        (Conf.api.passwords.include? id) && (password == Conf.api.passwords[id])
      end
      @id = id
    end
end



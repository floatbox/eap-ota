# encoding: utf-8
class ApiOrderStatsController < ApplicationController
  before_filter :authenticate

  def index
    orders = Order.where(:created_at=>Date.parse(params[:date_start])..Date.parse(params[:date_end] || Date.today.strftime('%Y/%m/%d')), :partner => @id, :payment_status => 'charged').includes(:secured_payments, :tickets)
    render :json => orders.every.api_stats_hash.to_json
  end

  private
    def authenticate
      authenticate_or_request_with_http_basic do |id, password|
        @id = id
        password && Conf.api.passwords[id] == password
      end
    end
end



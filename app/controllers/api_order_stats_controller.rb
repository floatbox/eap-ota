# encoding: utf-8
class ApiOrderStatsController < ApplicationController
  before_filter :authenticate

  def index
    end_date = (Date.parse(params[:date_end] || Date.today.strftime('%Y/%m/%d'))) + 1.day
    orders = Order.where(:created_at=>Date.parse(params[:date_start])..end_date, :partner => @id)
      .where('payment_status IN ("charged", "blocked")')
      .includes(:secured_payments, :tickets)
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



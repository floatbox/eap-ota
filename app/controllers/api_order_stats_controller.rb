# encoding: utf-8
class ApiOrderStatsController < ApplicationController
  before_filter :authenticate

  def index
    unless params[:date_start]
      render :text => "Lack of required parameter(s)  - date_start"
      return
    end
    end_date = (Date.parse(params[:date_end] || Date.today.strftime('%Y/%m/%d'))) + 1.day
    orders = Order.where(:created_at=>Date.parse(params[:date_start])..end_date, :partner => @id)
      .where('payment_status IN ("charged", "blocked")')
      .includes(:secured_payments, :tickets)
    respond_to do |format|
      format.json  { render :json => orders.every.api_stats_hash}
      format.csv { render :csv => orders.every.api_stats_hash}
      format.html { render :json => orders.every.api_stats_hash.to_json}
    end
  end

  private
    def authenticate
      authenticate_or_request_with_http_basic do |id, password|
        @id = id
        password && Partner.authenticate(id, password)
      end
    end
end



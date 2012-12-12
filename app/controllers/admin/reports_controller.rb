# encoding: utf-8
class Admin::ReportsController < Admin::BaseController

  def index
  end

  def selling
    default_date = Time.now
    #default_date = '2012/04/22'.to_time
    #mongo_default_date = '2012/05/05'.to_time.strftime(StatCounters::DATE_FORMAT)
    @date = [ 
      params[:date1] ? params[:date1] : default_date.strftime(StatCounters::DATE_FORMAT),
      params[:date2] ? params[:date2] : default_date.yesterday.strftime(StatCounters::DATE_FORMAT) ]

    @report = []
    @date.each do |d|
      data = {}
      data[:orders] = StatReports.get_orders_data StatReports.build_datetime_conditions('created_at', d)
      data[:percent_total] = data[:orders].order_total ? (data[:orders].income_total / data[:orders].order_total) * 100 : 0
      data[:percent_fare] = data[:orders].fare_total ? (data[:orders].income_total / data[:orders].fare_total) * 100 : 0
      data[:tickets] = StatReports.get_tickets_data StatReports.build_datetime_conditions('created_at', d)
      
      mongo_date_condition = StatCounters.build_datetime_conditions '_id', d
      data[:searches] = 0
      StatCounters.on_daterange(mongo_date_condition).each do |day_result|
        puts day_result.inspect
        data[:searches] += day_result['search']['api']['total'] + day_result['search']['total']
      end
      data[:searches_per_order] = !data[:searches].zero? ? data[:orders].order_count.to_f / data[:searches].to_f  * 100 : 0

      data[:top_carriers] = StatReports.top_carriers StatReports.build_datetime_conditions('created_at', d)
      @report << data
    end
  end

end
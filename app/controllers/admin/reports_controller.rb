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
      # data[:tickets] = StatReports.get_tickets_data StatReports.build_datetime_conditions('created_at', d)
      data[:ticket_average] = data[:orders].ticket_count ? (data[:orders].order_total.to_f / data[:orders].ticket_count.to_f) : 0
      data[:days] = StatReports.daterange_days d
      data[:day_total] = data[:orders].order_total ? (data[:orders].order_total / data[:days]) : 0
      data[:day_income] = data[:orders].income_total ? (data[:orders].income_total / data[:days]): 0

      # Top Carriers
      data[:top_carriers] = StatReports.top_carriers StatReports.build_datetime_conditions('created_at', d)

      # Top Partners
      data[:partners] = {}
      data[:top_partners] = StatReports.top_partners StatReports.build_datetime_conditions('created_at', d)
      data[:top_partners].each do |tp|
        tp.partner = 'eviterra' if !tp.partner
        data[:partners][tp.partner] = {}
        data[:partners][tp.partner][:orders] = tp
        data[:partners][tp.partner][:search] = 0
        data[:partners][tp.partner][:enter] = 0
      end

      mongo_date_condition = StatCounters.build_datetime_conditions('_id', d)
      data[:searches] = 0
      data[:enter] = 0
      StatCounters.on_daterange(mongo_date_condition).each do |day_result|
        if day_result['search']
          data[:searches] += day_result['search']['api']['total'] if day_result['search']['api']
          data[:searches] += day_result['search']['total'] if day_result['search']['total']
        end
        if day_result['enter']
          data[:enter] += day_result['enter']['preliminary_booking']['total'] if day_result['enter']['preliminary_booking']
        end

        # Partners Counters
        if day_result['search'] && day_result['search']['api']
          day_result['search']['api'].each do |partner, value|
            if !partner.blank? && value.class == BSON::OrderedHash
              data[:partners][partner][:search] += value['total']
            end
          end
        end

        if day_result['enter'] && day_result['enter']['preliminary_booking']
          day_result['enter']['preliminary_booking'].each do |partner, value|
            if !partner.blank? && value.class == BSON::OrderedHash
              data[:partners][partner][:enter] += value['total']
            end
          end
        end

      end

      data[:partners]['eviterra'][:search] = data[:searches] if data[:partners]['eviterra']
      data[:partners]['eviterra'][:enter] = data[:enter] if data[:partners]['eviterra']
      data[:partners].each do |name, partner|
        partner[:conv] = !partner[:enter].zero? ? (partner[:orders].order_count / partner[:enter].to_f) * 100 : 0
        partner[:markup] = !partner[:orders].order_total.zero? ? (partner[:orders].income_total / partner[:orders].order_total) * 100 : 0
      end

      data[:searches_per_order] = !data[:searches].zero? ? data[:orders].order_count.to_f / data[:searches].to_f  * 100 : 0

      @report << data
    end
  end

end
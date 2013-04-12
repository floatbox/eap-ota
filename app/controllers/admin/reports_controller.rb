# encoding: utf-8
class Admin::ReportsController < Admin::BaseController

  def index
  end

  def sales
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
        data[:partners][tp.partner][:enter_success] = 0
      end

      mongo_date_condition = StatCounters.build_datetime_conditions('_id', d)
      data[:searches] = 0
      data[:eviterra_searches] = 0
      data[:enter] = 0
      data[:enter_success] = 0
      data[:api_enter] = 0
      data[:api_enter_success] = 0
      StatCounters.on_daterange(mongo_date_condition).each do |day_result|
        if day_result['search']
          data[:searches] += day_result['search']['api']['total'] if day_result['search']['api']
          data[:searches] += day_result['search']['total'] if day_result['search']['total']
          data[:eviterra_searches] += day_result['search']['total'] if day_result['search']['total']
        end
        if day_result['enter']
          data[:enter] += day_result['enter']['preliminary_booking']['total'] if day_result['enter']['preliminary_booking']
          data[:enter_success] += day_result['enter']['preliminary_booking']['success'] if day_result['enter']['preliminary_booking']
        end

        # Partners Counters
        if day_result['search'] && day_result['search']['api']
          day_result['search']['api'].each do |partner, value|
            if !partner.blank? && value.class == Hash
              data[:partners][partner] = {} if !data[:partners][partner]
              data[:partners][partner][:search] = 0 if !data[:partners][partner][:search]
              data[:partners][partner][:search] += value['success'] if value['success']
            end
          end
        end

        if day_result['enter'] && day_result['enter']['preliminary_booking']
          day_result['enter']['preliminary_booking'].each do |partner, value|
            if !partner.blank? && value.class == Hash
              data[:partners][partner] = {} if !data[:partners][partner]

              data[:partners][partner][:enter] = 0 if !data[:partners][partner][:enter]
              data[:partners][partner][:enter] += value['total'] if value['total']

              data[:partners][partner][:enter_success] = 0 if !data[:partners][partner][:enter_success]
              data[:partners][partner][:enter_success] += value['success'] if value['success']

              data[:api_enter] += value['total'] if value['total']
              data[:api_enter_success] += value['success'] if value['success']
            end
          end
        end

      end

      data[:partners]['eviterra'][:search] = data[:eviterra_searches] if data[:partners]['eviterra']
      data[:partners]['eviterra'][:enter] = data[:enter] - data[:api_enter] if data[:partners]['eviterra']
      data[:partners]['eviterra'][:enter_success] = data[:enter_success] - data[:api_enter_success] if data[:partners]['eviterra']
      data[:partners].each do |name, partner|
        partner[:order_count] = partner[:orders] && partner[:orders].order_count ? partner[:orders].order_count : 0
        partner[:order_total] = partner[:orders] && partner[:orders].order_total ? partner[:orders].order_total : 0
        partner[:order_total_share] = partner[:order_total] ? partner[:order_total].to_f / data[:orders].order_total.to_f * 100 : 0
        partner[:income_total] = partner[:orders] && partner[:orders].income_total ? partner[:orders].income_total : 0
        partner[:income_share] = partner[:income_total] ? partner[:income_total].to_f / data[:orders].income_total.to_f * 100 : 0
        partner[:conv] = partner[:enter] && !partner[:enter].zero?  ? (partner[:order_count] / partner[:enter].to_f) * 100 : 0
        partner[:conv_success] = partner[:enter_success] && !partner[:enter_success].zero?  ? (partner[:order_count] / partner[:enter_success].to_f) * 100 : 0
        partner[:successes_per_enter] = partner[:enter] && !partner[:enter].zero?  ? (partner[:enter_success] / partner[:enter].to_f) * 100 : 0
        partner[:enters_per_search] = partner[:search] && !partner[:search].zero? && partner[:enter] ? (partner[:enter] / partner[:search].to_f) * 100 : 0
        partner[:markup] = !partner[:order_total].zero? ? (partner[:income_total] / partner[:order_total]) * 100 : 0
      end

      data[:orders_per_search] = !data[:searches].zero? ? data[:orders].order_count.to_f / data[:searches].to_f  * 100 : 0
      data[:enters_per_search] = !data[:searches].zero? ? data[:enter].to_f / data[:searches].to_f  * 100 : 0
      data[:successes_per_enter] = !data[:enter].zero? ? data[:enter_success].to_f / data[:enter].to_f  * 100 : 0
      data[:conv] = !data[:enter].zero? ? data[:orders].order_count.to_f / data[:enter].to_f  * 100 : 0
      data[:conv_success] = !data[:enter_success].zero? ? data[:orders].order_count.to_f / data[:enter_success].to_f  * 100 : 0

      @report << data
    end
  end

end

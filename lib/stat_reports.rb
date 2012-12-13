# encoding: utf-8
class StatReports

  def self.get_orders_data date_range
    Order.select('
      COUNT(*) as order_count,
      SUM(price_with_payment_commission) as order_total,
      AVG(price_with_payment_commission) as order_average,
      SUM(price_fare) as fare_total,
      SUM(price_with_payment_commission - price_tax - price_fare) as income_total,
      AVG(price_with_payment_commission - price_tax - price_fare) as income_average').reported.where(date_range).first
  end

  def self.get_tickets_data date_range
    Ticket.select('
      COUNT(*) as ticket_count,
      SUM(price_tax + price_fare) as ticket_total,
      AVG(price_tax + price_fare) as ticket_average').reported.where(date_range).first
  end

  def self.top_carriers date_range
    total = Ticket.reported.where(date_range).count
    top = Ticket.reported.where(date_range).count(:all, :group => 'tickets.validating_carrier')
    top_number = 5
    top = top.sort_by { |k,v| v }.last(top_number).reverse
    output = ''
    top.each do |t|
      t << t[1]*100/total
      output = output + t[0].to_s + ' ' + t[2].to_s + '% ( ' + t[1].to_s + ' )<br>'
    end
    output.html_safe
  end

  def self.build_datetime_conditions(key, value)
    firstdate, lastdate = value.strip.split('-')
    lastdate ||= firstdate
    ["#{key} BETWEEN ? AND ?", firstdate.to_date.beginning_of_day.to_s(:db), lastdate.to_date.end_of_day.to_s(:db)]
  end

end

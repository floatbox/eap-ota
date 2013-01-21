# encoding: utf-8
class StatReports

  def self.get_orders_data date_range
    Order.select('
      COUNT(*) as order_count,
      SUM(price_with_payment_commission) as order_total,
      AVG(price_with_payment_commission) as order_average,
      SUM(price_fare) as fare_total,
      SUM(blank_count) as ticket_count,
      SUM(stored_income) as income_total,
      AVG(stored_income) as income_average').reported.where(date_range).first
  end

  def self.get_tickets_data date_range
    Ticket.select('
      COUNT(*) as ticket_count,
      SUM(price_tax + price_fare) as ticket_total,
      AVG(price_tax + price_fare) as ticket_average').reported.where(date_range).first
  end

  def self.top_carriers date_range, top_number = 10
    tickets = Order.reported.where(date_range).sum(:blank_count, :group => 'commission_carrier')
    all_tickets = tickets.inject(0){|sum, (k,v)| sum + v}
    top = tickets.sort_by { |k,v| v }.last(top_number).reverse
    all_top = top.inject(0){|sum, v| sum + v[1]}
    iatas = top.collect {|k,v| k}
    carriers = Carrier.select('iata, color, en_shortname AS title').where(:iata => iatas)
    colors = {}
    carriers.collect {|c| colors[c.iata] = [c.color, c.title]}
    top_carriers = []
    top.each do |item|
      top_carriers << {:iata => item[0], :tickets => item[1], :color =>colors[item[0]].first, :title =>colors[item[0]].last}
    end
    top_carriers << {:iata => 'Other', :tickets => all_tickets - all_top, :color =>'ccc'}
    top_carriers
  end

  def self.top_partners date_range
    tickets = Order.select('
      COUNT(*) as order_count,
      SUM(price_with_payment_commission) as order_total,
      SUM(stored_income) as income_total,
      partner').reported.where(date_range).group(:partner).order('partner IS NULL DESC, order_count DESC')
  end

  def self.build_datetime_conditions(key, value)
    firstdate, lastdate = value.strip.split('-')
    lastdate ||= firstdate
    ["#{key} BETWEEN ? AND ?", firstdate.to_date.beginning_of_day.to_s(:db), lastdate.to_date.end_of_day.to_s(:db)]
  end

  def self.daterange_days(value)
     firstdate, lastdate = value.strip.split('-')
     lastdate ||= firstdate
     (lastdate.to_date - firstdate.to_date).round.abs + 1
  end

end

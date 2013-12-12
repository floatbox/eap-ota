# encoding: utf-8
module Admin::TicketsHelper

  def top_carriers tickets
    tickets = tickets.dup
    total = tickets.reorder('').count.to_f
    top = tickets.reorder('').count(:all, group: 'validating_carrier', order: 'count_all DESC', limit: 10)
    output = top.each_with_index.map do |carrier_data, index|
      percentage = (carrier_data[1] / total * 100).round(2)
      "#{(index + 1)}. #{carrier_data[0]} — #{carrier_data[1]} (#{percentage}%)<br>"
    end.join('')

    #top.inspect
    output.html_safe
  end

end

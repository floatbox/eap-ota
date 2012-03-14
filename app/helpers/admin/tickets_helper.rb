# encoding: utf-8
module Admin::TicketsHelper
  
  def top_carriers tickets
    top_number = 10
    total = tickets.count
    top = tickets.count(:all, :group => :validating_carrier)
    top = top.sort_by { |k,v| v }.last(top_number).reverse
    output = ''
    counter = 0
    top.each do |t|
      t << t[1]*100/total
      counter = counter + 1
      output = output + counter.to_s + '. ' + t[0].to_s + ' - ' + t[1].to_s + ' (' + t[2].to_s + '%)<br>'
    end
    
    #top.inspect
    output.html_safe
  end
  
end

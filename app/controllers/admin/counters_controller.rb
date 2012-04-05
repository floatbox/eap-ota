# encoding: utf-8
class Admin::CountersController < Admin::BaseController
  def index
    @tabs = (0..6).to_a.reverse.map {|t| t.days.ago.strftime(StatCounters::DATE_FORMAT) }
    @data = StatCounters.debug_yml(StatCounters.on_date(params[:date] || @tabs.last))
  end

  def destinations
    @date_range = params[:date] ? params[:date] : Time.now.strftime(StatCounters::DATE_FORMAT)
    @date_condition = StatCounters.build_datetime_conditions 'date', @date_range
    @partners = Order.partners
    @data = []
    day_data = {}
    total_s = 0
    total_e = 0
    count = 2000
    
    StatCounters.search_on_daterange(@date_condition, count).each do |day_direction|
      direction_index = day_direction['from'] + Destination.rts.invert[day_direction['rt']] + day_direction['to']
      day_data[direction_index] = {} if day_data[direction_index].nil?
      day_data[direction_index]['search'] = StatCounters.deep_merge_sum(day_data[direction_index]['search'], day_direction['search'])
      day_data[direction_index]['enter'] = StatCounters.deep_merge_sum(day_data[direction_index]['enter'], day_direction['enter'])
      total_s += day_direction.nested('search.api.total') || 0
      total_e += day_direction.nested('enter.api.total') || 0
    end
    @data = { :title => @date_range, :day_data => day_data, :total_s => total_s, :total_e => total_e }
  
  end

end

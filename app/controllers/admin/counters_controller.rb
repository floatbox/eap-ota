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
    @total_search = 0
    @total_enter = 0
    @total_partner = {}
    count = 2000

    @partners.each do |partner|
      @total_partner[partner] = {} if @total_partner[partner].nil?
      @total_partner[partner]['search'] = 0
      @total_partner[partner]['enter'] = 0
    end

    StatCounters.search_on_daterange(@date_condition, count).each do |day_direction|
      direction_index = day_direction['from'] + Destination.rts.invert[day_direction['rt']] + day_direction['to']
      if day_data[direction_index].nil?
        day_data[direction_index] = {}
        day_data[direction_index]['search'] = {}
        day_data[direction_index]['enter'] = {}
        day_data[direction_index]['search']['api'] = {}
        day_data[direction_index]['enter']['api'] = {}
        @partners.each do |partner|
          day_data[direction_index]['search']['api'][partner] = {}
          day_data[direction_index]['enter']['api'][partner] = {}
          day_data[direction_index]['search']['api'][partner]['total'] = 0
          day_data[direction_index]['enter']['api'][partner]['total'] = 0
        end
      end
      day_data[direction_index]['search'] = StatCounters.deep_merge_sum(day_data[direction_index]['search'], day_direction['search'])
      day_data[direction_index]['enter'] = StatCounters.deep_merge_sum(day_data[direction_index]['enter'], day_direction['enter'])
      @total_search += day_direction['search']['api']['total'] if day_direction['search'] && day_direction['search']['api']
      @total_enter += day_direction['enter']['api']['total'] if day_direction['enter']

      @partners.each do |partner|
        @total_partner[partner]['search'] += day_direction['search']['api'][partner]['total'] if day_direction['search'] && day_direction['search']['api'] && day_direction['search']['api'][partner]
        @total_partner[partner]['enter'] += day_direction['enter']['api'][partner]['total'] if day_direction['enter'] && day_direction['enter']['api'][partner]
      end
    end
    @partners.delete_if {|partner| @total_partner[partner]['search'].zero?}
    @data = { :title => @date_range, :day_data => day_data }
  end

end

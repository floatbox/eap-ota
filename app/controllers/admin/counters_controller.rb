# encoding: utf-8
class Admin::CountersController < Admin::BaseController
  def index
    @tabs = (0..6).to_a.reverse.map {|t| t.days.ago.strftime(StatCounters::DATE_FORMAT) }
    @data = StatCounters.debug_yml(StatCounters.on_date(params[:date] || @tabs.last))
  end

  def destinations
    count = 2000
    @tabs = (0..6).to_a.reverse.map {|t| t.days.ago.strftime(StatCounters::DATE_FORMAT) }
    @data = []
    @tabs.each do |date|
      day_data = []
      total_s = 0
      total_e = 0
      # FIXME WTF is i? daily_counters? or what?
      StatCounters.search_on_date(date, count).each do |i|
        day_data << i
        total_s += i.nested('search.api.total') || 0
        total_e += i.nested('enter.api.total') || 0
      end
      @data << { :title => date, :day_data => day_data, :total_s => total_s, :total_e => total_e }
    end
  end

end

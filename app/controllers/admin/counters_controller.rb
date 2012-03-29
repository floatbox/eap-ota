# encoding: utf-8
class Admin::CountersController < Admin::BaseController
  def index
    @tabs = (0..6).to_a.reverse.map {|t| t.days.ago.strftime(StatCounters::DATE_FORMAT) }
    @data = StatCounters.debug_yml(StatCounters.on_date(params[:date] || @tabs.last))
  end

  def destinations
    count = 1500
    @tabs = (0..6).to_a.reverse.map {|t| t.days.ago.strftime(StatCounters::DATE_FORMAT) }
    @data = []
    @tabs.each do |date|
      day_data = []
      total_s = 0
      total_e = 0
      StatCounters.search_on_date(date, count).each do |i|
        day_data << i
        total_s = total_s + i['search']['api']['total'] if !i['search'].blank?
        total_e = total_e + i['enter']['api']['total'] if !i['enter'].blank?
      end
      @data << { :title => date, :day_data => day_data, :total_s => total_s, :total_e => total_e }
    end
  end

end

# encoding: utf-8
class Admin::CountersController < Admin::BaseController
  def index
    @tabs = (0..6).to_a.reverse.map {|t| t.days.ago.strftime(StatCounters::DATE_FORMAT) }
    @data = StatCounters.debug_yml(StatCounters.on_date(params[:date] || @tabs.last))
  end

  def destinations
    count = 500
    @tabs = (0..6).to_a.reverse.map {|t| t.days.ago.strftime(StatCounters::DATE_FORMAT) }
    @data = []
    @tabs.each do |date|
      day_data = []
      StatCounters.search_on_date(date, count).each {|i| day_data << i}
      @data << { :title => date, :day_data => day_data }
    end
  end

end

# encoding: utf-8
class Admin::CountersController < Admin::BaseController
  def index
    @data = StatCounters.debug_yml(StatCounters.on_date(Time.now))
  end

  def yesterday
    @data = StatCounters.debug_yml(StatCounters.on_date(1.day.ago))
    render :index
  end

end

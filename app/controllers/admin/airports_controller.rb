# encoding: utf-8
class Admin::AirportsController < Admin::ResourcesController
  def update_completer
    Completer.regen
    redirect_to :action => :list
  end
end

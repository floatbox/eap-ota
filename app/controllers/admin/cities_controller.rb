# encoding: utf-8
class Admin::CitiesController < Admin::ResourcesController
  def update_completer
    Completer.regen
    redirect_to :action => :list
  end
end

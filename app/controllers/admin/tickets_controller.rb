# encoding: utf-8
class Admin::TicketsController < Admin::ResourcesController
  include CustomCSV

  def ticket_raw
    get_object
    render :text => @item.raw
  end
end


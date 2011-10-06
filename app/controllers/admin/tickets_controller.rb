# encoding: utf-8
class Admin::TicketsController < Admin::EviterraResourceController
  include CustomCSV
  include Typus::Controller::Bulk

  def show_versions
    get_object
  end

  def ticket_raw
    get_object
    render :text => @item.raw
  end

  def new_refund
    @item = @resource.new(params[:resource])
    render :action => :new
  end

  def set_bulk_action
    add_bulk_action("Set ticketed date", "bulk_set_ticketed_date")
  end
  private :set_bulk_action

  def bulk_set_ticketed_date(ids)
    ids.each do |id|
      ticket = @resource.find(id)
      ticket.update_attribute(:ticketed_date, Date.today) unless ticket.ticketed_date
    end
    redirect_to :back
  end
  private :bulk_set_ticketed_date
end


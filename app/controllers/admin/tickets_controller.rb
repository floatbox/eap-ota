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

  def change_vat
    get_object
    @item.update_attribute(:vat_status, params[:vat_status])
    redirect_to :action => 'show',
                :controller => 'orders',
                :id => @item.order.id
  end

  def new_refund
    @item = @resource.new(params[:resource])
    @item.route = @item.parent.route
    # callback же пересчитает цену?
    @item.price_discount = @item.parent.price_discount
    render :action => :new
  end

  def confirm_refund
    @item = @resource.find(params[:id])
    if @item.status != 'processed'
      @item.status = 'processed'
    else
      @item.status = 'pending'
      @item.ticketed_date = nil
    end
    render :action => :edit
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


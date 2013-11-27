# encoding: utf-8
class Admin::TicketsController < Admin::EviterraResourceController
  include CustomCSV
  include Typus::Controller::Bulk

  def create
    super
    if @item.order
      @item.order.recalculate_prices
      @item.order.update_has_refunds
    end
  end

  def update
    super
    if @item.order
      @item.order.recalculate_prices
      @item.order.update_has_refunds
    end
  end

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
    if @item.parent.fee < 0
      @item.price_discount = -@item.parent.fee
    else
      @item.price_our_markup = -@item.parent.fee
    end

    # с указанной даты начинаем проставлять сбор за возврат
    # FIXME не очень контроллеровая логика.
    @item.price_operational_fee = Ticket.default_refund_fee(@item.parent.order.created_at)
    render :action => :new
  end

  def delete_refund
    get_object
    @item.destroy if !@item.processed && @item.kind == 'refund'
    redirect_to :action => 'show',
                :controller => 'orders',
                :id => @item.order.id
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


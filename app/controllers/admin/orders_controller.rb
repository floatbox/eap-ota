# encoding: utf-8
class Admin::OrdersController < Admin::EviterraResourceController
  include CustomCSV
  include Typus::Controller::Bulk

  before_filter :find_order, :only => [:show_pnr, :unblock, :charge, :money_received, :no_money_received, :ticket, :cancel, :reload_tickets, :update, :pnr_raw, :void, :make_payable_by_card, :send_invoice, :ticket_in_ticketing_office, :manual_notice]

  # def set_scope
  #   # добавлять фильтры лучше в def index и т.п., но так тоже работает (пока?)
  #   # Title, url, scope (можно пропустить, не будет счета)
  #   add_predefined_filter 'Unticketed', {:scope => 'unticketed'}, 'unticketed'
  #   add_predefined_filter 'Ticketed', {:scope => 'ticketed'}, 'ticketed'
  #   scope = params[:scope]
  #  if %W[unticketed ticketed].include?(scope)
  #    @resource = @resource.send(scope)
  #  end
  # end

  def index
    # так тоже можно. просто выставляет параметры обычных фильтров
    add_predefined_filter 'Unticketed', Order.unticketed.scope_attributes, 'unticketed'
    add_predefined_filter 'Processing Ticket', Order.processing_ticket.scope_attributes, 'processing_ticket'
    add_predefined_filter 'Error Ticket', Order.error_ticket.scope_attributes, 'error_ticket'
    add_predefined_filter 'Ticket Not Sent', Order.ticket_not_sent.scope_attributes, 'ticket_not_sent'
    add_predefined_filter 'MOWR228FA', {:scope => 'MOWR228FA'}
    add_predefined_filter 'MOWR2233B', {:scope => 'MOWR2233B'}
    add_predefined_filter 'MOWR221F9', {:scope => 'MOWR221F9'}
    add_predefined_filter 'MOWR2219U', {:scope => 'MOWR2219U'}
    add_predefined_filter 'FLL1S212V', {:scope => 'FLL1S212V'}
    # FIXME для наших дейт-фильтров нужен формат 2012/2/21 вместо 2012-02-21
    #add_predefined_filter 'Today', {:created_at => Date.today.to_s(:db)}
    #add_predefined_filter 'Yesterday', {:created_at => Date.yesterday.to_s(:db)}
    super
  end

  # FIXME копипаста из тайпуса, чтобы добавить вызов set_attributes_on_new.
  # надеюсь, в будущих версиях тайпуса - выковыряем
  def new
    @item = @resource.new(params[:resource])

    set_attributes_on_new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @item }
    end
  end

  def show_versions
    get_object
  end

  def show_pnr
    notice = {}
    notice[:id] = @order.pnr_number
    notice[:format] = params[:format] if params[:format]
    notice[:lang] = "en" if params[:lang]
    redirect_to show_notice_path(notice)
  end

  def pnr_raw
    render :text => @order.raw
  end

  def send_invoice
    InvoiceMailer.notice(@order.id, params[:comment]).deliver
    respond_to do |format|
      format.html { render :nothing => true }
      format.js   { render :nothing => true }
    end
  end

  def unblock
    if @order.unblock!
      flash[:notice] = 'Деньги разблокированы'
    else
      flash[:alert] = "Произошла ошибка"
    end
    redirect_to :action => :show, :id => @order.id
  end

  def charge
    if @order.charge!
      flash[:notice] = 'Деньги списаны с карты'
    else
      flash[:alert] = "Произошла ошибка"
    end
    redirect_to :action => :show, :id => @order.id
  end

  def money_received
    @order.money_received!
    redirect_to :controller => 'admin/payments', :action => :edit, :id => @order.last_payment.id
  end

  def no_money_received
    @order.no_money_received!
    redirect_to :action => :show, :id => @order.id
  end

  def make_payable_by_card
    @order.make_payable_by_card
    redirect_to :action => :show, :id => @order.id
  end

  def ticket
    flash[:alert] = 'не удалось загрузить все билеты' unless @order.ticket!
    redirect_to :action => :show, :id => @order.id
  end

  def cancel
    # может упасть и не изменить статус?
    @order.strategy.cancel
    redirect_to :action => :show, :id => @order.id
  end

  def reload_tickets
    @order.reload_tickets
    redirect_to :action => :show, :id => @order.id
  end

  def manual_notice
    @order.email_manual!
    redirect_to :action => :show, :id => @order.id
  end

  def ticket_in_ticketing_office
    @order.strategy.ticket
    if @order.ticket!
      flash[:notice] = 'Билеты загружены'
    else
      LoadTicketsJob.new(:order_id => @order.id).delay
      flash[:notice] = 'Билеты в процессе выписки. Они будут загружены в ближайшее время'
    end
    redirect_to :action => :show, :id => @order.id
  rescue Strategy::TicketError => e
    flash[:alert] = e.message.presence || 'Странная ошибка. Скажите, если случится.'
    redirect_to :action => :show, :id => @order.id
  end

  def find_order
    @order = Order.find(params[:id])
  end

  def void
    @order.strategy.void
    redirect_to :action => :show, :id => @order.id
  end

  private

  def set_bulk_action
    add_bulk_action("Charge", "bulk_charge")
  end

  def bulk_charge(ids)
    ids.each { |id| @resource.find(id).charge! }
    notice = Typus::I18n.t("Tried to charge #{ids.count} entries. Probably successfully")
    redirect_to :back, :notice => notice
  end

  def set_attributes_on_new
    @item.offline_booking = true
  end
end


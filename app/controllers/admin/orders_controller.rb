# encoding: utf-8
require 'lib/typus/orm/active_record/search.rb'
class Admin::OrdersController < Admin::ResourcesController
  include CustomCSV
  include Typus::Controller::Bulk

  before_filter :find_order, :only => [:show_pnr, :unblock, :charge, :money_received, :no_money_received, :ticket, :cancel, :reload_tickets, :update, :resend_email, :send_offline_email]
  before_filter :update_offline_booking_flag, :only => :create

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
    add_predefined_filter 'Today', {:created_at => Date.today.to_s(:db)}
    add_predefined_filter 'Yesterday', {:created_at => Date.yesterday.to_s(:db)}
    super
  end

  def update
    super 
  end

  def show_pnr
    redirect_to show_order_path(:id => @order.pnr_number)
  end

  def unblock
    if @order.unblock!
      flash[:message] = 'Деньги разблокированы'
    else
      flash[:error] = "Произошла ошибка"
    end
    redirect_to :action => :show, :id => @order.id
  end

  def charge
    if @order.charge!
      flash[:message] = 'Деньги списаны с карты'
    else
      flash[:error] = "Произошла ошибка"
    end
    redirect_to :action => :show, :id => @order.id
  end

  def money_received
    @order.money_received!
    redirect_to :action => :show, :id => @order.id
  end

  def no_money_received
    @order.no_money_received!
    redirect_to :action => :show, :id => @order.id
  end

  def ticket
    res = @order.ticket!
    redirect_to :action => :show, :id => @order.id
  end

  def cancel
    # может упасть и не изменить статус?
    Strategy.new(:order => @order).cancel
    redirect_to :action => :show, :id => @order.id
  end

  def reload_tickets
    @order.reload_tickets
    redirect_to :action => :show, :id => @order.id
  end

  def resend_email
    @order.resend_email!
    redirect_to :action => :show, :id => @order.id
  end

  def send_offline_email
    @order.send_email
    redirect_to :action => :show, :id => @order.id
  end

  def find_order
    @order = Order.find(params[:id])
  end

  def update_offline_booking_flag
    params[:order][:offline_booking] = '1'
  end


  def set_bulk_action
    add_bulk_action("Charge", "bulk_charge")
  end
  private :set_bulk_action

  def bulk_charge(ids)
    ids.each { |id| @resource.find(id).charge! }
    notice = Typus::I18n.t("Tried to charge #{ids.count} entries. Probably successfully")
    redirect_to :back, :notice => notice
  end
  private :bulk_charge
end


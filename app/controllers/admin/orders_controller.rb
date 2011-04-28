# encoding: utf-8
class Admin::OrdersController < Admin::ResourcesController
  before_filter :find_order, :except => [:list, :new, :show, :csv]

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
    res = @order.cancel!
    redirect_to :action => :show, :id => @order.id
  end

  def find_order
    @order = Order.find(params[:id])
  end

end


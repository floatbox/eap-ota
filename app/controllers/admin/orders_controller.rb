# encoding: utf-8
class Admin::OrdersController < Admin::ResourcesController
  def edit
    redirect_to :action => :show, :id => params[:id]
  end

  def show_pnr
    order = Order.find(params[:id])
    redirect_to show_order_path(:id => order.pnr_number)
  end

  def unblock
    @order = Order.find(params[:id])
    if @order.unblock!
      flash[:message] = 'Деньги разблокированы'
    else
      flash[:error] = "Произошла ошибка"
    end
    redirect_to :action => :show, :id => @order.id
  end

  def charge
    @order = Order.find(params[:id])
    if @order.charge!
      flash[:message] = 'Деньги списаны с карты'
    else
      flash[:error] = "Произошла ошибка"
    end
    redirect_to :action => :show, :id => @order.id
  end

  def ticket
    @order = Order.find(params[:id])
    res = @order.ticket!
    redirect_to :action => :show, :id => @order.id
  end

  def cancel
    @order = Order.find(params[:id])
    res = @order.cancel!
    redirect_to :action => :show, :id => @order.id
  end

end


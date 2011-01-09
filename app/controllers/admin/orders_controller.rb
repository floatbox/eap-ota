class Admin::OrdersController < Admin::ResourcesController
=begin
  def show
    @order = Order.find(params[:id])
    #@pnr = Pnr.get_by_number params[:id]
    
    #redirect_to pnr_form_path(order.pnr_number)
  end
=end

  def unblock
    @order = Order.find(params[:id])
    res = @order.unblock
    if res["Success"] == "True"
      flash[:message] = 'Деньги возвращены'
    else
      flash[:error] = "Произошла ошибка #{res["ErrCode"]}"
    end
    redirect_to :action => :show, :id => @order.id
  end

  def charge
    @order = Order.find(params[:id])
    res = @order.charge
    if res["Success"] == "True"
      flash[:message] = 'Успешно'
    else
      flash[:error] = "Произошла ошибка #{res["ErrCode"]}"
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
    res = @order.cancel
    redirect_to :action => :show, :id => @order.id
  end

end

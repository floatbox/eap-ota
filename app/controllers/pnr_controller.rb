class PNRController < ApplicationController
  def create
    @pnr_form = PNRForm.new params[:pnr_form]
    if @pnr_form.valid?
      res = @pnr_form.get_pnr
      if res.length == 6
        @pnr_form.create_order(res)
        PnrMailer.deliver_pnr_notification(@pnr_form, res) if @pnr_form.email
        redirect_to :controller => 'PNR', :action => "show", :id => res
      else
        render :text => @pnr_form.get_pnr
      end
    else
      render :edit
    end
  end
  
  def show
    @pnr = Pnr.get_by_number params[:id]
  end
end

class PNRController < ApplicationController
  # FIXME не используется?
  def create
    @pnr_form = PNRForm.new params[:pnr_form]
    if @pnr_form.valid?
      res = @pnr_form.get_pnr
      if res.length == 6
        @pnr_form.create_order(res)
        # FIXME почему оно и тут тоже?
        PnrMailer.notification(@pnr_form.email, res).deliver if @pnr_form.email
        redirect_to :controller => 'PNR', :action => "show", :id => res
      else
        render :text => @pnr_form.get_pnr
      end
    else
      render :edit
    end
  end

  def new
    @pnr_form = PNRForm.new(:flight_codes => params[:flight_codes].split('_'))
    render :edit
  end

  def show
    @pnr = Pnr.get_by_number params[:id]
  end
end


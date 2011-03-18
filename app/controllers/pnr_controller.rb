# encoding: utf-8
class PNRController < ApplicationController
  def show
    @pnr = Pnr.get_by_number params[:id]
    if @pnr.order.source == 'sirena'
      render :text => @pnr.sirena_receipt, :content_type => 'application/pdf'
    end
  end
end


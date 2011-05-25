# encoding: utf-8
class PNRController < ApplicationController

  rescue_from RuntimeError, :with => :error

  def show
    @pnr = Pnr.get_by_number params[:id]
  end

  def error
    render 'error'
  end

  # sirena pdf receipt FIXME unfinished, unused
  def receipt
    @pnr = Pnr.get_by_number params[:id]
    if @pnr.order && @pnr.order.source == 'sirena'
      render :text => @pnr.sirena_receipt, :content_type => 'application/pdf'
    end
  end
end


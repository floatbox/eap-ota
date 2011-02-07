# encoding: utf-8
class PNRController < ApplicationController
  def show
    @pnr = Pnr.get_by_number params[:id]
  end
end


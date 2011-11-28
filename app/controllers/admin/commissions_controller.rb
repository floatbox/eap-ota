# encoding: utf-8
class Admin::CommissionsController < Admin::BaseController
  def index
    @commissions = Commission.all
  end

  def table
    @commissions = Commission.all
    @as_table = true
    render :index
  end

  def check
    @recommendation =
      if params[:example].present?
        Recommendation.example(params[:example], :carrier => params[:carrier])
      elsif params[:code].present?
        Recommendation.deserialize(params[:code])
      # FIXME сделать возможность копипастить из терминала
      # elsif params[:terminal].present?
      #
      end
    @commissions_with_reasons = Commission.all_with_reasons_for(@recommendation)
  end

end

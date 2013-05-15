# encoding: utf-8
class Admin::CommissionsController < Admin::BaseController
  def index
    @commissions = book.all
  end

  def table
    @commissions = book.all
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
    @commissions_with_reasons = book.all_with_reasons_for(@recommendation)
  end

  private

  # TODO задел на работу с несколькими коллекциями
  def book
    Commission.default_book
  end

end

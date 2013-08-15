# encoding: utf-8
class Admin::CommissionsController < Admin::BaseController
  def index
    @book = book
  end

  def table
    @book = book
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
    if @recommendation
      @rules_with_reasons = book.all_with_reasons_for(@recommendation)
    end
  end

  def page
    date = params[:date] && Date.parse(params[:date])
    carrier = params[:carrier]
    @page = book.find_page(carrier: carrier, date: date)
  end

  private

  # TODO задел на работу с несколькими коллекциями
  def book
    Commission.default_book
  end

end

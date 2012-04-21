# encoding: utf-8
class Admin::HotOffersController < Admin::EviterraResourceController
  def best_of_the_week
     @hot_offers = HotOffer.where(:created_at.gte => (Date.today-7.days)).and(:rt => true).and(:price_variation_percent => 15...45).order_by(:price_variation_percent => :desc)
     @hot_offers.all.group_by{ |h|  h.to_iata && h.price}.values.every.first
     render :index
  end

  private

  # монгоидные ресурсы используют order_by на классе,
  # и принимают аргументы массивом, а не одной строкой
  def set_order
    params[:sort_order] ||= "desc"

    if (order = params[:order_by] ? [params[:order_by], params[:sort_order]] : @resource.typus_order_by).present?
      @resource = @resource.order_by(order)
    end
  end
end

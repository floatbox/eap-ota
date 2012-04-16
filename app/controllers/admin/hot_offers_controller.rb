# encoding: utf-8
class Admin::HotOffersController < Admin::EviterraResourceController
  def best_of_the_week
     @hot_offers = HotOffer.where(:created_at.gte => (Date.today-7.days)).and(:rt => true).and(:price_variation_percent => 15...45).order_by(:price_variation_percent => :desc)
     @hot_offers.all.group_by{ |h|  h.to_iata && h.price}.values.every.first
     render :index
  end
end

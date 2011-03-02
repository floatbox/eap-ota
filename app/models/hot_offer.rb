# encoding: utf-8
class HotOffer < ActiveRecord::Base
  attr_writer :recommendation
  belongs_to :destination
  before_create :set_some_vars

  def clickable_url
    "<a href=#{url}>#{url}</a>".html_safe
  end

  def search= val
    @search = val
    self.for_stats_only = @search.people_count.values.sum > 1
    self.description = @search.human_lite
  end

  private

  def set_some_vars
    self.price = @recommendation.price_total / @search.people_count.values.sum
    self.time_delta = (Date.strptime(@search.form_segments[0].date, '%d%m%y') - Date.today).to_i
    self.destination = Destination.find_or_create_by_from_id_and_to_id_and_rt(@search.form_segments[0].from_as_object.id, @search.form_segments[0].to_as_object.id, @search.rt)
    unless destination.new_record?
      destination.average_price = (destination.hot_offers.every.price.sum + price) / (destination.hot_offers.count + 1)
      destination.average_time_delta = (destination.hot_offers.every.time_delta.sum + time_delta) / (destination.hot_offers.count + 1)
    else
      destination.average_price = price
      destination.average_time_delta = time_delta
    end
    destination.save
    self.price_variation = destination.average_price - price
    self.price_variation_percent = ((price / destination.average_price.to_f - 1)*100).to_i
  end

end


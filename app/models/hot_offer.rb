# encoding: utf-8
class HotOffer < ActiveRecord::Base
  attr_writer :recommendation
  belongs_to :destination
  before_create :set_some_vars
  delegate :rt, :to => :destination
  after_create :create_notifications

  def create_notifications
    destination.subscriptions.active.every.create_notice(self) if !for_stats_only && destination.hot_offers_counter >= 20 && price_variation_percent <= -10
  end

  def self.featured code=nil
    # FIXME SQL group_by не был бы лучше?
    offers = where("for_stats_only = ? AND price_variation < 0", false).order('created_at DESC').limit(30)
    # эта строчка, видимо, не используется
    offers = offers.where("code != ?", code) if code
    offers.all.group_by(&:destination_id).values.every.first
  end

  def clickable_url
    "<a href=#{url}>#{url}</a>".html_safe
  end

  def search= val
    @search = val
    self.for_stats_only = @search.people_count.values.sum > 1
    self.description = @search.human_lite
  end

  def pricer_form
    @pricer_form ||= PricerForm.load_from_cache(code)
  end

  private

  def set_some_vars
    self.price = @recommendation.price_with_payment_commission / @search.people_count.values.sum
    self.time_delta = (Date.strptime(@search.segments[0].date, '%d%m%y') - Date.today).to_i
    destination = Destination.find_or_initialize_by_from_id_and_to_id_and_rt(@search.segments[0].from_as_object.id, @search.segments[0].to_as_object.id, @search.rt)
    self.date1 = @search.segments[0].date_as_date
    self.date2 = @search.segments[1].date_as_date if @search.segments[1]
    unless destination.new_record?
      destination.average_price += (price - destination.average_price) / (destination.hot_offers.count + 1)
      destination.average_time_delta +=  (time_delta - destination.average_time_delta) / (destination.hot_offers.count + 1)
    else
      destination.average_price = price
      destination.average_time_delta = time_delta
    end
    destination.hot_offers_counter += 1
    destination.save
    ## херова магия, иначе при создании hot_offer у него не было destination_id
    self.destination = destination
    self.price_variation = price - destination.average_price
    self.price_variation_percent = ((price / destination.average_price.to_f - 1)*100).to_i
  end

end


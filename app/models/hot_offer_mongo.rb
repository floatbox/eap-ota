# encoding: utf-8
class   HotOfferMongo

  include Mongoid::Document
  field :code, :type => String
  field :url, :type => String
  field :description, :type => String
  field :price, :type => Integer
  field :for_stats_only, :type => Boolean
  field :destination_id, :type => Integer
  field :time_delta, :type => Integer
  field :price_variation, :type => Integer
  field :price_variation_percent, :type => Integer

  belongs_to :destination_mongo
  before_create :set_some_vars

  validates_presence_of :code, :url, :description, :price

  attr_writer :recommendation


  def self.featured code=nil
    # FIXME SQL group_by не был бы лучше?
    offers = HotOffer.where("for_stats_only" => false ).and(:price_variation.gt => 0).order_by(:created_at => :desc).limit(30)
    # эта строчка, видимо, не используется
    offers = offers.where(:code.ne => code) if code
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

  private

  def set_some_vars
    if @search and @recommendation
        self.price = @recommendation.price_with_payment_commission / @search.people_count.values.sum
        self.time_delta = (Date.strptime(@search.segments[0].date, '%d%m%y') - Date.today).to_i
        self.destination_mongo = DestinationMongo.find_or_create_by(:from_id => @search.segments[0].from_as_object.id, :to_id => @search.segments[0].to_as_object.id, :rt => @search.rt)
      unless destination_mongo.new_record?
          destination_mongo.average_price = (destination_mongo.hot_offers.every.price.sum + price) / (destination_mongo.hot_offers.count + 1)
          destination_.average_time_delta = (destination_mongo.hot_offers.every.time_delta.sum + time_delta) / (destination_mongo.hot_offers.count + 1)
      else
        destination_mongo.average_price = price
        destination_mongo.average_time_delta = time_delta
      end
      destination_mongo.hot_offers_counter += 1
      destination_mongo.save
      self.price_variation =  price - destination_mongo.average_price
      self.price_variation_percent = ((price / destination_mongo.average_price.to_f - 1)*100).to_i
    end
end

end


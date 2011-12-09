# encoding: utf-8
class HotOffer

  include Mongoid::Document
  include Mongoid::Timestamps
  field :code, :type => String
  field :url, :type => String
  field :to_iata, :type => String
  field :from_iata, :type => String
  field :date1, :type => String
  field :rt, :type => Boolean
  field :description, :type => String
  field :price, :type => Integer
  field :for_stats_only, :type => Boolean
  field :destination_id, :type => Integer
  field :time_delta, :type => Integer
  field :price_variation, :type => Integer
  field :price_variation_percent, :type => Integer

  belongs_to :destination
  before_create :set_some_vars

  validates_presence_of :code, :url, :description, :price

  attr_writer :recommendation

  def create_notifications
    Subscription.where(:from_iata => destination.from.iata, :to_iata => destination.to.iata, :rt => destination.rt).active.every.create_notice(self) if !for_stats_only && destination.hot_offers_counter >= 20 && price_variation_percent <= -20
  end

  def self.featured code=nil
    # FIXME SQL group_by не был бы лучше?
    offers = HotOffer.where(:for_stats_only => false ).and(:price_variation.gt => 0).order_by(:created_at => :desc).limit(30)
    # эта строчка, видимо, не используется
    offers = offers.where(:code.ne => code) if code
    offers.all.group_by{|h| h.from_iata && h.to_iata && h.rt}.values.every.first
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
        self.from_iata = @search.segments[0].from_as_object.iata
        self.to_iata = @search.segments[0].to_as_object.iata
        self.rt = @search.rt
        self.date1 = Date.strptime(@search.segments[0].date, '%d%m%y')
        self.time_delta = (Date.strptime(@search.segments[0].date, '%d%m%y') - Date.today).to_i
        self.destination = Destination.find_or_create_by(:from_iata => @search.segments[0].from_as_object.iata, :to_iata => @search.segments[0].to_as_object.iata, :rt => @search.rt)
        unless destination.new_record?
                 destination.average_price = (destination.hot_offers.every.price.sum + price) / (destination.hot_offers.count + 1)
                 destination.average_time_delta = (destination.hot_offers.every.time_delta.sum + time_delta) / (destination.hot_offers.count + 1)
               else
                 destination.average_price = price
                 destination.average_time_delta = time_delta
               end

        self.price_variation =  price - destination.average_price
        self.price_variation_percent = ((price / destination.average_price.to_f - 1)*100)

        destination.hot_offers_counter += 1
        destination.save
    end
  end

end

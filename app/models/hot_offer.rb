# encoding: utf-8
class HotOffer

  include Mongoid::Document
  include Mongoid::Timestamps
  field :code, :type => String
  field :url, :type => String
  field :to_iata, :type => String
  field :from_iata, :type => String
  field :date1, :type => String
  field :date2, :type => String
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
  after_create :create_notifications

  validates_presence_of :code, :url, :description, :price

  attr_writer :recommendation

  class << self
    # алиас, чтобы тайпус видел, что ресурс умеет сортировку
    alias :order :order_by

    # FIXME сделать модуль или фикс для typus, этим оверрайдам место в typus/application.yml
    def model_fields
      super.merge(
        :price => :decimal,
        :price_variation_percent => :decimal
      )
    end

    # рейс еще не улетел
    def actual
      where(:date1.gt => Date.today)
    end

    # спец скоуп для Вани
    def superscoup
      where(:from_iata => {'$in' => ['MSK', 'MOW', 'LED']})
    end
  end

  def create_notifications
    Subscription.where(:from_iata => destination.from.iata, :to_iata => destination.to.iata, :rt => destination.rt).active.every.create_notice(self) if !for_stats_only && destination.hot_offers_counter >= 20 && price_variation_percent <= -20
  end

  # не воткнуть ли сюда #actual в цепочку? а то, потенциально, может показать старые предложения
  def self.featured code=nil
    # FIXME SQL group_by не был бы лучше?
    offers = HotOffer.where(:for_stats_only => false ).and(:price_variation.gt => 0).order_by(:created_at => :desc).limit(30)
    offers = offers.where(:code.ne => code) if code
    offers.to_a.uniq_by {|h| [h.from_iata, h.to_iata, h.rt]}
  end

  def clickable_url
    "<a href=#{url}>#{url}</a>".html_safe
  end

  def date1_as_date
    Date.parse date1
  end

  def date2_as_date
    Date.parse date2 if date2
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
        self.date2 = Date.strptime(@search.segments[1].date, '%d%m%y') if @search.segments[1]
        self.time_delta = (Date.strptime(@search.segments[0].date, '%d%m%y') - Date.today).to_i
        self.destination = Destination.find_or_create_by(:from_iata => @search.segments[0].from_as_object.iata, :to_iata => @search.segments[0].to_as_object.iata, :rt => @search.rt)
        if destination.average_price
#          hot_offers_count = destination.hot_offers.count + 1
#          destination.average_price = destination.hot_offers.every.price.sum / hot_offers_count
#          destination.average_time_delta = destination.hot_offers.every.time_delta.sum / hot_offers_count
          destination.average_price = destination.hot_offers_counter.to_f/(destination.hot_offers_counter + 1)*destination.average_price + price/(destination.hot_offers_counter + 1)
          destination.average_time_delta = destination.hot_offers_counter.to_f/(destination.hot_offers_counter + 1)*destination.average_time_delta + time_delta/(destination.hot_offers_counter + 1)
        else
          destination.average_price = price
          destination.average_time_delta = time_delta
        end

        self.price_variation =  price - destination.average_price
        self.price_variation_percent = ((price / destination.average_price.to_f - 1)*100)

        destination.hot_offers_counter += 1
        destination.save
#        self.price_variation_percent < -10
    end
  end

end

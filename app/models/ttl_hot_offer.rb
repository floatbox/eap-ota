# encoding: utf-8
class TtlHotOffer
  # Time To Live index for 5 days
  #db.ttl_hot_offers.ensureIndex({"updated_at": 1}, {expireAfterSeconds: 432000})
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
    Subscription.where(:from_iata => from_iata, :to_iata => to_iata, :rt => rt).active.every.create_notice(self) if !for_stats_only && destination.average_price_counter >= 50 && price_variation_percent <= -15
  end

  # не воткнуть ли сюда #actual в цепочку? а то, потенциально, может показать старые предложения
  def self.featured code=nil
    # FIXME SQL group_by не был бы лучше?
    offers = HotOffer.where(:for_stats_only => false ).and(:price_variation.lt => 0).order_by(:created_at => :desc).limit(30)
    offers = offers.where(:code.ne => code) if code
    offers.to_a.uniq_by {|h| [h.from_iata, h.to_iata, h.rt]}
  end

  def self.price_map from_iata=nil, rt=nil, date=nil
    fromdate = Date.strptime(date, '%d%m%y')
    fromdate = Date.tomorrow if fromdate < Date.tomorrow
    todate = fromdate.months_since(2)

    if Date.today.month == fromdate.month 
      searchdays = 1
    else
      searchdays = 2
    end

    offers = TtlHotOffer.where(
      :for_stats_only => false,
      :date1.gte => fromdate,
      :date1.lt => todate,
      :created_at.gte => Date.today - searchdays
      ).and(:price_variation_percent.lt => - 10).order_by(:price_variation_percent => :asc)
    offers = offers.where(:from_iata => from_iata) if from_iata
    offers = offers.where(:rt => rt) if rt
    offers = offers.where(:date2.lt => todate) if rt.to_i == 1

    offers = offers.to_a.uniq_by {|h| [h.from_iata, h.to_iata, h.rt]}[0..150]

    iatas = offers.collect{|h| [h.to_iata, h.from_iata]}.flatten.uniq
    cities = City.where(:iata => iatas)
    city_hash = Hash[ *cities.to_a.collect { |v| [ v.iata, v ] }.flatten ]
    offers.each { |h|
      h[:from] = city_hash[h.from_iata]
      h[:to] = city_hash[h.to_iata]
      h
    }
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
    self.url = Conf.site.host + '/#' + code
  end

  private

  def set_some_vars

    logger.info "Create HotOffer: price = #{price}"

    if @search and @recommendation
        self.from_iata = @search.segments[0].from_as_object.iata
        self.to_iata = @search.segments[0].to_as_object.iata
        self.rt = @search.rt
        self.date1 = Date.strptime(@search.segments[0].date, '%d%m%y')
        self.date2 = Date.strptime(@search.segments[1].date, '%d%m%y') if @search.segments[1]
        self.time_delta = (Date.strptime(@search.segments[0].date, '%d%m%y') - Date.today).to_i    
        self.price_variation =  price - destination.average_price
        self.price_variation_percent = ((price / destination.average_price.to_f - 1)*100)    
    end
  end

end

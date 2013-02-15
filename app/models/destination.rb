# encoding: utf-8
class Destination
  include Mongoid::Document
  include Mongoid::Timestamps

  extend Typus::Orm::Base

  field :to_iata, :type => String
  field :from_iata, :type => String
  field :rt, :type => Boolean
  field :average_price, :type => Integer
  field :average_time_delta, :type => Integer
  field :hot_offers_counter, :type => Integer, :default => 0
  field :recalculated, :type => Boolean
  field :average_price_counter, :type => Integer, :default => 0


  has_many :ttl_hot_offers, :dependent => :destroy

  def self.rts
    { ' → ' => false, ' ⇄ ' => true}
  end

  def name
    "#{from.name} #{Destination.rts.invert[rt]} #{to.name}"
  end

  def from
    City.find_by_iata from_iata
  end

  def to
    City.find_by_iata to_iata
  end

  def self.table_name
      collection_name
  end

  def self.build_conditions (*)

  end

  def average_interval
    200
  end

  def move_average_price search, recommendation, query_key
    if (!search.complex_route? &&
        search.people_count.values.sum == search.people_count[:adults] &&
        ([nil, '', 'Y'].include? search.cabin) &&
        search.segments[0].to_as_object.class == City && search.segments[0].from_as_object.class == City)
      price = recommendation.price_with_payment_commission / search.people_count.values.sum
      logger.info "Destination: (#{from_iata}-#{to_iata}) rt=#{rt} average_price = #{average_price}. New price = #{price}"

      if average_price && average_price > 0 && average_price_counter > 0
        logger.info "Exist Destination"
        self.average_price = ((average_interval - 1)*average_price + price).to_f/average_interval.to_f
      else
        logger.info "New Destination"
        self.average_price = price
      end
      self.average_price_counter += 1

      if average_price > price
        logger.info "Create Hot Offer for Destination"
        ttl_hot_offers.create(
        :code => query_key,
        :search => search,
        :recommendation => recommendation,
        :price => price)
      end

      if average_price > 0
        logger.info "Save Destination average_price = #{average_price}"
        save!
      end
    end
  end

  def nullify
    ttl_hot_offers.delete_all
    update_attributes :average_price => nil, :average_time_delta => nil, :hot_offers_counter => 0
  end

  def self.get_by_search search
    segment = search.segments[0]
    return if ([segment.to_as_object.class, segment.from_as_object.class] - [City, Airport]).present? || search.complex_route?
    to = segment.to_as_object.class == Airport ? segment.to_as_object.city : segment.to_as_object
    from = segment.from_as_object.class == Airport ? segment.from_as_object.city : segment.from_as_object
    find_or_create_by(:from_iata => from.iata, :to_iata => to.iata , :rt => search.rt)
  end

end


# encoding: utf-8
class Subscription < ActiveRecord::Base
  belongs_to :destination

  validates :email, :presence => true,
                    :length => {:minimum => 3, :maximum => 254},
                    :format => {:with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i}

  scope :active, where(:status => '')
  scope :frozen, where(:status => 'frozen')
  scope :disabled, where(:status => 'disable')
  scope :to_defrost, lambda {
    where(:status => 'frozen')\
      .where("updated_at < ?", 11.hours.ago)
  }

  def self.statuses
    ['frozen', 'disable']
  end
  
  def freeze
    update_attribute(:status, 'frozen')
  end

  def defrost
    update_attribute(:status, '') if status == 'frozen'
  end

  def disable
     update_attribute(:status, 'disable')
  end

  def create_notice(hot_offer)
    rt_date = human_date(hot_offer.date2) if hot_offer.date2
    notice_info = {
      :id => id,
      :destination_id => destination_id,
      :email => email,
      :city_from => City.find(destination.from_id).case_from,
      :from_date => human_date(hot_offer.date1),
      :city_to => City.find(destination.to_id).case_to,
      :city_rt_from => City.find(destination.to_id).case_from,
      :rt_date => rt_date,
      :rt => destination.rt,
      :description => hot_offer.description,
      :price => human_price(hot_offer.price),
      :query_key => hot_offer.code
    }
    Qu.enqueue SubscriptionMailer, notice_info
  end

  def human_date(d)
    if d.year == Date.today.year
      return I18n.l(d, :format => '%e %B')
    else
      return I18n.l(d, :format => '%e %B %Y')
    end
  end

  def human_price(price)
    rounded = price.round.to_i
    "#{ rounded } #{ Russian.pluralize(rounded, 'рубль', 'рубля', 'рублей') }"
  end

  def self.defrost_frozen!
      Subscription.to_defrost.every.defrost
  end

end

# encoding: utf-8
class Subscription < ActiveRecord::Base
  belongs_to :destination

  scope :active, where(:status => '')
  scope :frozen, where(:status => 'frozen')
  
  def freeze
    update_attribute(:status, 'frozen')    
  end

  def create_notice(hot_offer)
    notice_info = {
      :destination_id => destination_id,
      :destination_id => destination_id,
      :email => email,
      :city_from => City.find(destination.from_id).case_from,
      :from_date => human_date(hot_offer.date1),
      :city_to => City.find(destination.to_id).case_to,
      :city_rt_from => City.find(destination.to_id).case_from,
      :rt_date => human_date(hot_offer.date2),
      :rt => destination.rt,
      :description => hot_offer.description,
      :price => hot_offer.price,
      :query_key => hot_offer.code
    }
    Qu.enqueue SubscriptionMailer, notice_info
  end
  
  def human_date(ds)
    d = Date.strptime(ds, '%d%m%y')
    if d.year == Date.today.year
      return I18n.l(d, :format => '%e&nbsp;%B')
    else
      return I18n.l(d, :format => '%e&nbsp;%B %Y')
    end
  end

end
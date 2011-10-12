# encoding: utf-8
class Subscription < ActiveRecord::Base
  belongs_to :destination


  def create_notice(hot_offer)
    notice_info = {
      :destination_id => destination_id,
      :email => email,
      :city_from => City.find(destination.from_id).case_from,
      :from_date => '',
      :city_to => City.find(destination.to_id).case_to,
      :city_rt_from => City.find(destination.to_id).case_from,
      :rt_date => '',
      :rt => destination.rt,
      :description => hot_offer.description,
      :price => hot_offer.price,
      :query_key => hot_offer.code
    }
    Qu.enqueue SubscriptionMailer, notice_info
  end

end
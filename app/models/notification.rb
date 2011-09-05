# encoding: utf-8
class Notification < ActiveRecord::Base

  belongs_to :order
  belongs_to :typus_user

  # before_create :set_payment_status


  def self.create_email order_id

    order = Order.find order_id
    notify = Notification.new(
      :order_id => order_id,
      :destination => order.email,
      :comment => '',
      :activate_at => Time.now
      )
    notify.save!


  end

end
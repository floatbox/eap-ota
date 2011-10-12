class SubscriptionController < ApplicationController

  def subscribe
    s = Subscription.find_or_initialize_by_destination_id_and_email(params[:destination_id], params[:email])
    if s.save
      render :json => {:success => true}
    else
      render :json => {:success => false}
    end
  end

  def unsubscribe
    subscription = Subscription.find_by_destination_id_and_email(params[:destination_id], params[:email])
    subscription.freeze
  end
end

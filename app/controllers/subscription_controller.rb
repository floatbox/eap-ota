# encoding: utf-8
class SubscriptionController < ApplicationController

  def subscribe
   # s = Subscription.find_or_initialize_by_destination_id_and_email(params[:destination_id], params[:email])
    s = Subscription.find_or_init(:email => params[:email], :from_iata => params[:from_iata], :to_iata => params[:to_iata], :rt => params[:rt] )

    if s.save
      render :json => {:success => true}
    else
      render :json => {:success => false}
    end
  end

  def unsubscribe
    subscription = Subscription.find_by_id_and_email(params[:subscription], params[:email])
    if subscription
      subscription.disable 
      @subscription = subscription
    else
      render "unsubscribe_not_found"
    end  
  end

  def unsubscribe_by_destination
    subscription = Subscription.find_by_destination_id_and_email(params[:destination_id], params[:email])
    subscription.disable if subscription
    @destination = Destination.find(params[:destination_id])
  end
end

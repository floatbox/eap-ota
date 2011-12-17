# encoding: utf-8
class Admin::PaytureChargesController < Admin::EviterraResourceController
  def index
    redirect_to :controller => 'admin/payments', :type => 'PaytureCharge'
  end
end

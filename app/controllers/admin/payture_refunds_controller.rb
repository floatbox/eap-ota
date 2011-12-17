# encoding: utf-8
class Admin::PaytureRefundsController < Admin::EviterraResourceController
  def index
    redirect_to :controller => 'admin/payments', :type => 'PaytureRefund'
  end
end

# encoding: utf-8
class Admin::PayuChargesController < Admin::EviterraResourceController
  def index
    redirect_to :controller => 'admin/payments', :type => 'PayuCharge'
  end
end

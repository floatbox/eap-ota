# encoding: utf-8
class Admin::CashChargesController < Admin::EviterraResourceController
  def index
    redirect_to :controller => 'admin/payments', :type => 'CashCharge'
  end
end

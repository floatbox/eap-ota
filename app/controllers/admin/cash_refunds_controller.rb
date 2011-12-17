# encoding: utf-8
class Admin::CashRefundsController < Admin::EviterraResourceController
  def index
    redirect_to :controller => 'admin/payments', :type => 'CashRefund'
  end
end

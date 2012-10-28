# encoding: utf-8
class Admin::PayuRefundsController < Admin::EviterraResourceController
  def index
    redirect_to :controller => 'admin/payments', :type => 'PayuRefund'
  end
end

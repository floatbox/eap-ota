# encoding: utf-8

class RapidaController < ApplicationController
  def payment
    get_params!
    rapida = Rapida.new
    response = case @command
    when 'check' then rapida.check *@requisites
    when 'pay' then rapida.pay *@requisites
    else return render :status => :not_acceptable, :text => 'command not allowed'
    end
    render text: response
  end

  private

  def get_params!
    @command = params[:command]
    txn_id = params[:txn_id]
    account = params[:account]
    sum = params[:sum]
    phone = params[:phone]
    @requisites = [txn_id, account, sum, phone]
  end

end


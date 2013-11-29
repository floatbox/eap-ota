# encoding: utf-8

class RapidaController < ApplicationController
  def payment
    get_params!
    rapida = Rapida.new *@requisites
    response = case @command
    when :check then rapida.check
    when :pay   then rapida.pay
    else rapida.unknown_command
    end
    render xml: response
  end

  private

  def get_params!
    @command = params[:command].to_sym
    @requisites = [params[:txn_id], params[:account], params[:sum], params[:phone] ]
  end

end


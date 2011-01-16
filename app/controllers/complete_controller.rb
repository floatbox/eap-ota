# encoding: utf-8
class CompleteController < ApplicationController

  def completer
    Completer
  end
  helper_method :completer

  def complete
    start_time = Time.now.to_f
    sleep(params[:delay].to_f) if params[:delay]
    text = params[:val]
    pos = params[:pos]
    limit = params[:limit] # || 20
    results = completer.complete(text, pos, :limit => limit)

    struct = {
      :stat => {:val => params[:val], :pos => params[:pos]},
      :data => results
    }

    render :json => struct.to_json, :callback => params[:callback]
  end
  
end

class CompleteController < ApplicationController
# -*- coding: utf-8 -*-

  # FIXME caching doesn't work in development mode
  @@completer = nil
  def completer
    Completer.new_or_cached
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

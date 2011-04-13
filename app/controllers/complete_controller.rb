# encoding: utf-8
class CompleteController < ApplicationController

  def complete
    val = params[:val]
    pos = params[:pos]
    limit = params[:limit]
    results = Completer.complete(val, pos, :limit => limit)

    struct = {
      :stat => {:val => val, :pos => pos},
      :data => results
    }

    render :json => struct.to_json, :callback => params[:callback]
  end

end

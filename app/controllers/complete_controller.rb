# encoding: utf-8
class CompleteController < ApplicationController

  def complete
    val = params[:val]
    pos = params[:pos]
    limit = params[:limit]
    results = Completer.complete(val, pos, :limit => limit)
    
    results = results.map{|item|
      entity = item[:entity]
      {
        :name => item[:name],
        :type => entity[:type],
        :iata => entity[:iata],
        :area => entity[:hint],
        :hint => entity[:info] || "#{ entity[:name] }, #{ entity[:hint] }",
      }
    }
    
    struct = {
      :query => val,
      :data => results
    }

    render :json => struct.to_json, :callback => params[:callback]
  end

end

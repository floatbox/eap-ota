# encoding: utf-8
class CompleteController < ApplicationController

  def complete
    # val - на время миграции, убрать позже
    query = params[:query] || params[:val]
    limit = params[:limit]
    results = Completer.localized(params[:language].presence).complete(query, :limit => limit)

    render :json => {query: query, data: results}.to_json, :callback => params[:callback]
  end

end

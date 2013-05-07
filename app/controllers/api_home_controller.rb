# encoding: utf-8
class ApiHomeController < ApplicationController
  def index
    message = "Eviterra API.\n"
    message+= "See docs at https://github.com/Eviterra/api/wiki\n"
    message+= "Send access requests to support@eviterra.com\n"
    render text: message, content_type: :text
  end

  def gone
    message = "That API endpoint is obsolete or disabled. Please upgrade."
    respond_to do |format|
      format.json { render json: {error: message}, status: :gone }
      format.xml  { render xml: "<error>#{message}</error>", status: :gone }
      format.any  { render text: message, status: :gone }
    end
  end
end

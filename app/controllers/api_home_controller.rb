# encoding: utf-8
class ApiHomeController < ApplicationController
  def index
    message = "Eviterra API.\n"
    message+= "See docs at https://github.com/Eviterra/api/wiki\n"
    message+= "Send access requests to support@eviterra.com\n"
    render text: message, content_type: :text
  end
end

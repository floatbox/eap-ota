# encoding: utf-8
class HotOffer < ActiveRecord::Base
  def clickable_url
    "<a href=#{url}>#{url}</a>".html_safe
  end
end
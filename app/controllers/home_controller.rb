# encoding: utf-8
class HomeController < ApplicationController

  before_filter :save_partner_cookies, :only => :index

  def index
  end

  # TODO сделать поддержку params[:language]
  # FIXME сделать и тут презентер? dict не должен быть в контроллере
  include TranslationHelper
  def whereami
    city = Location.nearest_city(request.remote_ip)
    render :json => {:city_name => dict(city)}
  end

  def status
    render text: 'ok'
  end

  def revision
    revision =
      if File.exists? 'REVISION'
        File.read 'REVISION'
      else
        `git log -1 --pretty=format:%H`
      end
    render text: revision
  end

  protected

end


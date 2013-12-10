# encoding: utf-8
class HomeController < ApplicationController
  include ContextMethods

  before_filter :save_partner_cookies, :only => :index
  before_filter :set_context_partner, :set_context_deck_user
  helper_method :context

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
    render text: sha
  end

  def pending
    redirect_to "https://github.com/Eviterra/eviterra/compare/#{sha}...master"
  end

  def current
    redirect_to "https://github.com/Eviterra/eviterra/commits/#{sha}"
  end

  protected

  # текущая ревизия в деплое или локально
  def sha
    if File.exists? 'REVISION'
      File.read 'REVISION'
    else
      `git log -1 --pretty=format:%H`
    end
  end

end


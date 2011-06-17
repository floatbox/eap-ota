# encoding: utf-8
class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  include Typus::Authentication::Session

  protected

  # 404 на старые урлы
  ActionDispatch::ShowExceptions.rescue_responses.update 'Cache::NotFound' => :not_found

  before_filter :set_admin_user
  #before_filter :authenticate
  def set_admin_user
    Typus::Configuration.models_constantized!
    @admin_user = Typus.user_class.find_by_id(session[:typus_user_id]) if session[:typus_user_id]
    # for hoptoad_notifier
    request.env['eviterra.admin_user'] = @admin_user.email if @admin_user
  end

  attr_reader :admin_user
  helper_method :admin_user

  # для хоптода
  def set_search_context
    request.env['eviterra.search'] = @search.human_lite rescue '[incomplete]'
  end

  def set_locale
    I18n.locale = :ru
  end

  before_filter :set_locale

  ActionView::Base.field_error_proc = Proc.new do |html_tag, instance|
    html_tag
  end

end


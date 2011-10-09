# encoding: utf-8
class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  include Typus::Authentication::Session

  protected

  # 404 на старые урлы
  ActionDispatch::ShowExceptions.rescue_responses.update 'Cache::NotFound' => :not_found

  before_filter :set_admin_user_for_airbrake
  def set_admin_user_for_airbrake
    request.env['eviterra.admin_user'] = admin_user.email if admin_user
  end
  helper_method :admin_user

  def corporate_mode?
    session[:corporate_mode]
  end
  helper_method :corporate_mode?

  # для хоптода
  def set_search_context_for_airbrake
    request.env['eviterra.search'] = @search.human_lite rescue '[incomplete]'
  end

  def set_locale
    I18n.locale = :ru
  end

  before_filter :set_locale

  def log_partner
    logger.info "API::Partner: #{cookies[:partner]}" if cookies[:partner]
  end
  after_filter :log_partner

  ActionView::Base.field_error_proc = Proc.new do |html_tag, instance|
    html_tag
  end

end


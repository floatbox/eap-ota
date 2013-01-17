# encoding: utf-8
class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  include Typus::Authentication::Session, PartnerTracking
  has_mobile_fu false

  before_filter :set_locale
  after_filter :log_partner

  protected

  helper_method :admin_user

  def corporate_mode?
    session[:corporate_mode]
  end
  helper_method :corporate_mode?

  def set_locale
    I18n.locale = :ru
  end

  def log_user_agent
    logger.info "UserAgent: #{request.user_agent}"
  end

  ActionView::Base.field_error_proc = Proc.new do |html_tag, instance|
    html_tag
  end

end


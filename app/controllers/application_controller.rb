# encoding: utf-8
class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  include Typus::Authentication::Session
  before_filter :set_typus_constantized
  #before_filter :authenticate
  def set_typus_constantized
    Typus::Configuration.models_constantized!
  end

  def admin_user
    @admin_user ||= ( id = session[:typus_user_id] && Typus.user_class.find_by_id(id) )
  end

  helper_method :admin_user

  protected

  def set_locale
    I18n.locale = :ru
  end

  before_filter :set_locale

  ActionView::Base.field_error_proc = Proc.new do |html_tag, instance|
    html_tag
  end

end

# encoding: utf-8
class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  if Rails.env.production?
     #TODO временно закрываем доступ для не залогиненых в админку
     include Typus::Authentication::Session
     before_filter :set_typus_constantized
     before_filter :authenticate
     def set_typus_constantized
        Typus::Configuration.models_constantized!
     end
  end

  protected

  def set_locale
    I18n.locale = :ru
  end

  before_filter :set_locale

  ActionView::Base.field_error_proc = Proc.new do |html_tag, instance|
    html_tag
  end

end

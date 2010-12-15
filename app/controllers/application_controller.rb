# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  #TODO временно закрываем доступ для не залогиненых в админку
  include Typus::Authentication
  before_filter :require_login

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password

  def rescue_action_without_handler(exception)
    unless request.xhr?
      super
      return
    end
    log_error(exception) if logger
    erase_results if performed?

    render :json => {
      :exception => {
        :message => exception.message,
        :backtrace => []
      }
    }
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


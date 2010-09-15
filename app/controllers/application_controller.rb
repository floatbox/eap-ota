# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details


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

  # TODO перенести в модуль какой-нибудь, что ли.
  def reset_amadeus_time
    PricerForm.reset_parse_time
    Amadeus.reset_request_time
  end

  def log_amadeus_time
    parse_time = PricerForm.parse_time || 0
    request_time = Amadeus.request_time || 0
    if !parse_time.zero?
      logger.debug "Last Amadeus pricer result (Request: %.2f, Parse: %.2f)" % [request_time, parse_time]
    end
  end

  def set_locale
    I18n.locale = :ru
  end

  before_filter :reset_amadeus_time, :set_locale
  after_filter :log_amadeus_time
  
  ActionView::Base.field_error_proc = Proc.new do |html_tag, instance|
    html_tag
  end

end


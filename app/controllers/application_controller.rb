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

end

# Notifies Rollbar, but silently continues execution
#
# Usage
#
# begin
#  ..
# rescue
#   with_warning
# end
module WithWarning

  def with_warning(exception=$!)
    Rails.logger.warn("Continued after #{exception.class}: #{exception.message}")
    (0...10).each { |i| Rails.logger.warn("#{exception.backtrace[i]}") }
    Rollbar.report_exception(exception)
  rescue => e
    Rails.logger.error("Can't notify Rollbar about warning #{exception.class}: #{exception.message} because of #{e.class}: #{e.message}")
  end

  # yanked from rails
  # actionpack/lib/action_dispatch/middleware/show_exceptions.rb
  #  ActiveSupport::Deprecation.silence do
  #    # выяснить, что делает именно :silent?
  #    backtrace = Rails.backtrace_cleaner.clean(exception.backtrace, :silent)
  #    message = "\n#{exception.class} (#{exception.message}):\n"
  #    message << "  " << backtrace.join("\n  ")
  #    Rails.logger.error("#{message}\n  ...reported and continued\n")
  #  end

end
Object.send :include, WithWarning

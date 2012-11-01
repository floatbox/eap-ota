#class NilClass
#  def empty?
#    true
#  end
#end
#ActiveSupport::Deprecation.debug = true

#ActiveSupport::Dependencies.log_activity = true
#ActiveSupport::Dependencies.logger = Rails.logger

#module DumbEventLogger
#  ActiveSupport::Notifications.subscribe do |event, |
#    Rails.logger.info "event: #{event}"
#  end
#end

# затыкаю логгер активрекорда. от него пользы не очень много
#require 'loggers/null_logger'
#ActiveRecord::Base.logger = Loggers::NullLogger

module Typus
  module I18n
    class << self
      ##
      # Instead of having to translate strings and defining a default value:
      #
      #     Typus::I18n.t("Hello World!", :default => 'Hello World!')
      #
      # We define this method to define the value only once:
      #
      #     Typus::I18n.t("Hello World!")
      #
      # Note that interpolation still works:
      #
      #     Typus::I18n.t("Hello %{world}!", :world => @world)
      #
      def t(msg, *args)
        options = args.extract_options!
        #options[:default] = nil
        ::I18n.t(msg, options)
      end
    end
  end
end

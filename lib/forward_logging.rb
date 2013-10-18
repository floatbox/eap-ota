require 'logger'
# Wraps any standard Logger, overriding it's level, if neccessary.
#
#   logger = Logger.new('development.log', Logger::INFO)
#   debug_logger = ForwardLogging.new(logger, Logger::DEBUG)
#   warn_logger = ForwardLogging.new(logger, Logger::WARN)
#
#   # this is the same as logger.info('foo')
#   debug_logger.debug('foo')
#
#   # this won't produce any message
#   warn_logger.info('foo')
#
#   # now it will follow level of parent_logger
#   warn_logger.level = nil
#   warn_logger.level == logger.level
#   => true
class ForwardLogging

  include Logger::Severity

  def initialize(logger, level=nil)
    @logger = logger
    @level = level
  end

  attr_accessor :logger
  attr_writer :level

  def level
    @level || @logger.level
  end

  def add(severity, message = nil, progname = nil, &block)
    return if severity < level
    # upgrade severity if it's lower than parent logger level
    @logger.add([severity, @logger.level].max, message, progname, &block)
  end

  Logger::Severity.constants.each do |severity|
    class_eval <<-EOT, __FILE__, __LINE__ + 1
      def #{severity.downcase}(message = nil, progname = nil, &block) # def debug(message = nil, progname = nil, &block)
        add(#{severity}, message, progname, &block)                   #   add(DEBUG, message, progname, &block)
      end                                                             # end

      def #{severity.downcase}?                                       # def debug?
        #{severity} >= level                                         #   DEBUG >= level
      end                                                             # end
    EOT
  end

end

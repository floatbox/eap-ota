# копипаста из Nesty::NestedError,
# с поправкой на парсер airbrake-а
module Errors
  module Nested
    attr_reader :nested, :raw_backtrace

    def initialize(msg = nested_message($!), nested = $!)
      super(msg)
      @nested = nested
    end

    def set_backtrace(backtrace)
      @raw_backtrace = backtrace
      # не работает в airbrake, он не умеет парсить нестандартные месседжи
      #
      # if nested
      #   backtrace = backtrace - nested_raw_backtrace
      #   backtrace += ["#{nested.backtrace.first}: #{nested.message} (#{nested.class.name})"]
      #   backtrace += nested.backtrace[1..-1] || []
      # end
      # super(backtrace)
      if nested
        backtrace += nested.backtrace
      end
      super(backtrace)
    end

    private

    def nested_raw_backtrace
      nested.respond_to?(:raw_backtrace) ? nested.raw_backtrace : nested.backtrace
    end

    def nested_message(exception)
      if exception.message
        "#{exception.class}: #{exception.message}"
      else
        exception.class.to_s
      end
    end
  end
end

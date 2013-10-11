module Amadeus
  class Error < StandardError
  end

  class SoapError < StandardError
    include ::Errors::Nested

    def self.wrap(handsoap_error)
      handsoap_error.is_a? Handsoap::Fault or
        raise ArgumentError, "not a Handsoap::Fault given: #{handsoap_error.inspect}"

      code, section, message = handsoap_error.reason.split('|')
      case code.to_i
      when 18, 3973
        SoapSyntaxError
      when 31, 91, 284, 1931
        SoapApplicationError
      when 42, 93, 357, 2162
        SoapNetworkError
      else
        SoapError
      end.new(handsoap_error.reason)
    end

  end

  # ошибки в синтаксисе или параметрах запроса
  class SoapSyntaxError < SoapError; end

  # ошибки в логике, во многом аналогичны Amadeus::Error
  # TODO отнаследовать?
  class SoapApplicationError < SoapError; end

  # проблемы с сетью и сессиями
  class SoapNetworkError < SoapError; end
end

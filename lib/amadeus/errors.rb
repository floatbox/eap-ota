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
      when 31, 284, 1931
        SoapApplicationError
      when 42, 357, 2162
        SoapNetworkError
      when 93
        SoapConversationError
      when 91
        SoapUnknownError
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

  # Амадеус сам не знает, что не так.
  class SoapUnknownError < SoapApplicationError; end

  # проблемы с сетью и сессиями
  class SoapNetworkError < SoapError; end

  # Счетчик в сессионном заголовке запроса не совпадает с ожидаемым.
  # Случается, если предыдущий запрос не дошел до Амадеуса, а мы инкрементнули счетчик.
  class SoapConversationError < SoapNetworkError; end
end

require 'amadeus'
module Amadeus
  class LogSubscriber < ActiveSupport::LogSubscriber

    def request(event)
      service = event.payload[:service]
      session = service.session
      request = event.payload[:request]
      request_summary = request.summary
      exception = event.payload[:exception]
      response = event.payload[:response]
      xml_response = event.payload[:xml_response]

      msg = "Amadeus::Service: "

      # FIXME сейчас предполагается, что сессия инкрементится до создания event.
      # это не верно в случае HTTP ошибок.
      msg << "#{color(request.action, GREEN)} (#{event.duration.to_i}ms)"
      msg << " (#{color(request_summary, CYAN)})" if request_summary
      msg << " #{session.token}(#{session.seq - 1})" if session
      msg << " error: #{color(response.error_message.to_s, RED)}" if response && !response.success?
      msg << " exception: #{color(exception.to_s, RED, true)}" if exception

      info(msg)

      # TODO перенести FileLogger и это все настройки сюда.
      if xml_response && !request.action =~ /Pricer/
        service.log_file(request.action, xml_response.to_xml)
      end
    end

    attach_to :amadeus
  end
end

# encoding: utf-8

require 'net/http'
require 'net/https'

module SMS
  # базовый класс для смс-гейтов
  # для упрощения кода можно убрать
  class Base

    class SMSError < StandardError; end

    def initialize(hash = {})
      @host = hash[:host] || Conf.sms.host
      @path = hash[:path] || Conf.sms.path
      @port = hash[:port] || Conf.sms.port
      @use_ssl = hash[:use_ssl] || true
    end

    def send_sms(*args)
      raise NotImplementedError
    end

    private

    def compose(messages)
      raise NotImplementedError
    end

    def parse_response(response)
      raise NotImplementedError
    end

    def invoke_post_request(request_body, parsed, host=@host, path=@path, port=@port, use_ssl=@use_ssl)
      endpoint = Net::HTTP.new(host, port)
      if @use_ssl
        endpoint.use_ssl = @use_ssl
        # не юзаем сертификат
        endpoint.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
      request = Net::HTTP::Post.new(path)
      request.body = request_body
      send(:"parse_#{parsed}_response", endpoint.request(request))
    rescue Timeout::Error, Errno::ECONNRESET, EOFError, SocketError, SMSError => e
      # ловить все подряд не хочется, а эти эксепешены вполне можно, я думаю
      with_warning(e)
      Rails.logger.info "Error occured while performing sms #{parsed}: #{e}"
      nil
    end

  end
end


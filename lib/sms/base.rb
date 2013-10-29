# encoding: utf-8

require 'net/http'
require 'net/https'

module SMS
  class Base

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

    def invoke_post_request(request_body, host=@host, path=@path, port=@port, use_ssl=@use_ssl)
      endpoint = Net::HTTP.new(host, port)
      if @use_ssl
        endpoint.use_ssl = @use_ssl
        # не юзаем сертификат
        endpoint.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
      request = Net::HTTP::Post.new(path)
      request.body = request_body
      parse_response(endpoint.request(request))
    end

  end
end


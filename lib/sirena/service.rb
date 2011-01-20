# encoding: utf-8
module Sirena

  class Service

    HOST = 'eviterra.com'#"127.0.0.1"
    PORT = 8888
    PATH = "/"

    class << self

      include FileLogger
      def debug_dir; 'log/sirena' end

      def action(name, params)
        request = Sirena::Request.for(name).new(params)
        request_body = request.render
        response_body = do_http(request_body)
        save_xml(name, response_body)
        response = Sirena::Response.for(name).new(response_body)
      end

      # FIXME заменить нафик на Curl::Easy
      def do_http(request)
        http = Net::HTTP.new(HOST, PORT)
        http_response = http.post(PATH, request)

        if http_response.code != '200'
          raise "HTTP error, status code: #{http_response.code}"
        end
        http_response.body
      end

      for method_name in %W(pricing availability describe schedule)
        define_method method_name.underscore do |params|
          action(method_name, params)
        end
      end

    end

  end

end

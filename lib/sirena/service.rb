# encoding: utf-8
module Sirena

  class Service

    HOST = Conf.sirena.host
    PORT = Conf.sirena.port
    PATH = Conf.sirena.path

    class << self

      include FileLogger
      def debug_dir; 'log/sirena' end
      def debug_file; 'log/sirena.log'; end

      def action(name, *params)
        request = Sirena::Request.for(name).new(*params)
        request_body = request.render
        if Conf.sirena.fake
          response_body = read_latest_xml(name)
        else
          log_request(name, request_body)
          response_body = do_http(request_body, :encrypt => request.encrypt?)
          log_response(name, response_body)
        end
        response = Sirena::Response.for(name).new(response_body)
      end

      def do_http(request, args={})
        # pricing: 150
        # client_summary: 100
        # superclient_summary: 150
        # остальные запросы: 40
        # выставляю пока для прайсера, с запасом
        http = Typhoeus::Easy.new
        http.timeout = 160 * 1000 # in ms
        http.url = "http://#{HOST}:#{PORT}#{PATH}"
        http.method = :post

        headers = {}
        headers['X-Encrypt'] = 'true' if args[:encrypt]
        headers['X-Timeout'] = (args[:timeout] || 155).to_s
        http.headers = headers

        http.request_body = request
        http.perform

        unless (200..299) === http.response_code
          raise HTTPError, "Status code: #{http.response_code}"
        end
        http.response_body
      end

      %W(pricing describe booking booking_cancel payment_ext_auth \
         order PNRHistory get_itin_receipts fareremark add_remark).each do |method_name|
        define_method method_name.underscore do |*params|
          action(method_name, *params)
        end
      end

      def log_request(name, request)
        open(debug_file, 'a') {|f|
          f.puts "==============="
          f.puts "Request: #{name}"
          f.puts "---------------"
          f << request
        }
      end

      def log_response(name, response)
        open(debug_file, 'a') {|f|
          f.puts "---------------"
          f << response
        }
        save_xml(name, response)
      end
    end

  end

  class HTTPError < RuntimeError
  end

end

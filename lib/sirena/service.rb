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
          response_body = do_http(request_body)
          log_response(name, response_body)
        end
        response = Sirena::Response.for(name).new(response_body)
      end

      # FIXME заменить нафик на Curl::Easy
      def do_http(request)
        # pricing: 150
        # client_summary: 100
        # superclient_summary: 150
        # остальные запросы: 40
        # выставляю пока для прайсера, с запасом
        http = Net::HTTP.new(HOST, PORT)
        http.read_timeout = 160
        http_response = http.post(PATH, request,
                                 'X-Timeout' => '155')

        unless http_response.is_a? Net::HTTPSuccess
          http_response.error!
        end
        http_response.body
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

end

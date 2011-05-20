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
          response_body = do_http(request_body, :encrypt => request.encrypt?, :timeout => request.timeout)
          log_response(name, response_body)
        end
        response = Sirena::Response.for(name).new(response_body)
      end

      def do_http(request, args={})
        req = Typhoeus::Request.new "http://#{HOST}:#{PORT}#{PATH}",
          :method => :post,
          :body => request,
          :timeout => 160 * 1000, # in ms
          :headers => {
            'X-Encrypt' => (args[:encrypt] ? 'true' : 'false'),
            'X-Timeout' => ((args[:timeout] || 150) + 5).to_s
          }
        Typhoeus::Hydra.hydra.queue req
        Typhoeus::Hydra.hydra.run

        req.response.body
      end

      %W(pricing describe booking booking_cancel payment_ext_auth \
         order PNRHistory get_itin_receipts fareremark add_remark pnr_status).each do |method_name|
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

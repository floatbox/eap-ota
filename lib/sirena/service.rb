# encoding: utf-8
module Sirena

  class Service

    module Methods

      include NewRelic::Agent::MethodTracer

      include KeyValueInit

      attr_accessor :driver

      def initialize(*)
        super
        # @driver ||= Sirena::TyphoeusDriver.new
        @driver ||= Sirena::MultiCurbDriver.new
      end

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
          response_body = driver.send_request(
            request_body,
            :encrypt => request.encrypt?,
            :timeout => request.timeout,
            :priority => request.priority
          )
          log_response(name, response_body)
        end
        request.process_response(response_body)
      end
      add_method_tracer :action, 'Custom/Sirena/http'

      # FIXME вернуть поддержку fake
      def async_action(name, *params, &block)
        request = Sirena::Request.for(name).new(*params)
        request_body = request.render
        log_request(name, request_body)
        driver.send_request_async(
          request_body,
          :encrypt => request.encrypt?,
          :timeout => request.timeout,
          :priority => request.priority
        ) do |response|
          log_response(name, response)
          block.call request.process_response(response)
        end
      end

      %W(pricing describe booking booking_cancel payment_ext_auth bill_static
         order PNRHistory get_itin_receipts fareremark add_remark pnr_status).each do |method_name|
        define_method method_name.underscore do |*params|
          action(method_name, *params)
        end
      end

      %W(pricing).each do |method_name|
        define_method "async_" + method_name.underscore do |*params, &block|
          async_action(method_name, *params, &block)
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
      add_method_tracer :log_request, 'Custom/Sirena/log'

      def log_response(name, response)
        open(debug_file, 'a') {|f|
          f.puts "---------------"
          f << response
        }
        save_xml(name, response)
      end
      add_method_tracer :log_response, 'Custom/Sirena/log'

    end
    include Methods

  end

end

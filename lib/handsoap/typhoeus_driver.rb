# -*- coding: utf-8 -*-
require 'handsoap/http/drivers/abstract_driver'
module Handsoap
  module Http
    module Drivers
      class TyphoeusDriver < AbstractDriver

        def self.load!
          require 'typhoeus'
        end

        def send_http_request(request)
          req = typhoeus_request(request)
          Typhoeus::Hydra.hydra.queue req
          Typhoeus::Hydra.hydra.run
          response = req.response
          parse_http_part(response.headers.gsub(/^HTTP.*\r\n/, ""), response.body, response.code)
        end

        def send_http_request_async(request)
          req = typhoeus_request(request)
          Typhoeus::Hydra.hydra.queue req

          deferred = Handsoap::Deferred.new
          req.on_complete do
            # сделать errback
            # deferred.trigger_errback emdef
            response = req.response
            http_response = parse_http_part(response.headers.gsub(/^HTTP.*\r\n/, ""), response.body, response.code)
            deferred.trigger_callback http_response
          end
          deferred
        end


        def typhoeus_request(request)
          Typhoeus::Request.new request.url,
            :username => request.username,
            :password => request.password,
            :ssl_cacert => request.trust_ca_file,
            :ssl_cert => request.client_cert_file,
            :ssl_key => request.client_cert_key_file,
            :headers => request.headers,
            :method => request.http_method,
            :body => request.body
        end

      end
    end
  end

end
Handsoap::Http.drivers[:typhoeus] = Handsoap::Http::Drivers::TyphoeusDriver

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
          http_client = Typhoeus::Easy.new
          http_client.url = request.url
          # begin of untested code
          if request.username && request.password
            http_client.auth = { :username => request.username, :password => request.password }
          end
          http_client.ssl_cacert = request.trust_ca_file if request.trust_ca_file
          http_client.ssl_cert = request.client_cert_file if request.client_cert_file
          http_client.ssl_key = request.client_cert_key_file if request.client_cert_key_file
          # end of untested code
          http_client.headers = request.headers
          http_client.method = request.http_method
          case request.http_method
          when :post, :put
            http_client.request_body = request.body
          end
          http_client.perform
          parse_http_part(http_client.response_header.gsub(/^HTTP.*\r\n/, ""), http_client.response_body, http_client.response_code)
        end

      end
    end
  end

end
Handsoap::Http.drivers[:typhoeus] = Handsoap::Http::Drivers::TyphoeusDriver

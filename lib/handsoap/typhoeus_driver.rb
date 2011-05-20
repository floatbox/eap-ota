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
          req = Typhoeus::Request.new request.url,
            :username => request.username,
            :password => request.password,
            :ssl_cacert => request.trust_ca_file,
            :ssl_cert => request.client_cert_file,
            :ssl_key => request.client_cert_key_file,
            :headers => request.headers,
            :method => request.http_method,
            :body => request.body
          Typhoeus::Hydra.hydra.queue req
          Typhoeus::Hydra.hydra.run

          response = req.response
          parse_http_part(response.headers.gsub(/^HTTP.*\r\n/, ""), response.body, response.code)
        end

      end
    end
  end

end
Handsoap::Http.drivers[:typhoeus] = Handsoap::Http::Drivers::TyphoeusDriver

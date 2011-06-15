# -*- coding: utf-8 -*-
require 'handsoap/http/drivers/abstract_driver'
module Handsoap
  class TyphoeusDriver < Handsoap::Http::Drivers::AbstractDriver

    def self.load!
      require 'typhoeus'
    end

    include KeyValueInit
    include TyphoeusHelper

    attr_accessor :hydra

    def initialize(*)
      super
      @hydra ||= Typhoeus::Hydra.hydra
    end

    def send_http_request(request)
      req = typhoeus_request(request)
      queue req

      run
      response = req.response
      raise_if_error response
      parse_http_part(response.headers.gsub(/^HTTP.*\r\n/, ""), response.body, response.code)
    end

    def send_http_request_async(request)
      req = typhoeus_request(request)
      queue req
      deferred = Handsoap::Deferred.new
      req.on_failure do |*args|
        deffered.trigger_errback args
      end
      req.on_success do
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

    def run
      hydra.run
    end

    def queue req
      hydra.queue req
    end
  end
end
Handsoap::Http.drivers[:typhoeus] = Handsoap::TyphoeusDriver

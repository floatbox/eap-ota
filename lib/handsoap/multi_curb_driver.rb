# -*- coding: utf-8 -*-
require 'handsoap/http/drivers/abstract_driver'

module Handsoap
  class MultiCurbDriver < Handsoap::Http::Drivers::AbstractDriver

    def self.load!
      require 'curb'
    end

    cattr_accessor :logger do
      Rails.logger
    end

    include CurlHelper
    include KeyValueInit

    attr_accessor :enable_cookies, :multi, :timeout, :connect_timeout, :follow_redirects

    def initialize(*)
      super
      @timeout ||= Handsoap.timeout
      @follow_redirects = Handsoap.follow_redirects? if @follow_redirects.nil?
      @max_redirects ||= Handsoap.max_redirects
      @multi ||= Curl::Multi.new
    end

    # raises Curl::Err::*
    def send_http_request(request)
      req = curl_request(request)
      req.perform
      parse_http_part(req.header_str.gsub(/^HTTP.*\r\n/, ""), req.body_str, req.response_code, req.content_type)
    ensure
      logger.info "#{self.class.name}: " + debug_easy(req)
    end

    def send_http_request_async(request)
      req = curl_request(request)
      deferred = Handsoap::Deferred.new
      # returns Curl::Err::* and message
      req.on_failure do |klass, msg|
        logger.info "#{self.class.name}: " + debug_easy(req)
        deffered.trigger_errback [klass, msg]
      end
      req.on_success do
        logger.info "#{self.class.name}: " + debug_easy(req)
        http_response = parse_http_part(req.header_str.gsub(/^HTTP.*\r\n/, ""), req.body_str, req.response_code, req.content_type)
        deferred.trigger_callback http_response
      end
      queue req
      deferred
    end

    def get_curl(url)
      curl                 = ::Curl::Easy.new(url)
      curl.timeout         = @timeout
      curl.connect_timeout = @connect_timeout
      curl.enable_cookies  = @enable_cookies
      # enables both deflate and gzip responses
      curl.encoding = ''

      if follow_redirects
        curl.follow_location = true
        curl.max_redirects   = Handsoap.max_redirects
      end
      curl
    end
    private :get_curl

    def curl_request(request)
      http_client = get_curl(request.url)
      # Set credentials. The driver will negotiate the actual scheme
      if request.username && request.password
        http_client.userpwd = [request.username, ":", request.password].join
      end
      http_client.cacert = request.trust_ca_file if request.trust_ca_file
      http_client.cert = request.client_cert_file if request.client_cert_file
      http_client.cert_key = request.client_cert_key_file if request.client_cert_key_file
      # pack headers
      headers = request.headers.inject([]) do |arr, (k,v)|
        arr + v.map {|x| "#{k}: #{x}" }
      end
      http_client.headers = headers

      # sets Conent-type to www-urlencoded as a side effect(?)
      http_client.post_body = request.body if request.body

      # FIXME придумать способ передавать метод.
      # Впрочем, мы все время используем POST
      #case request.http_method
      #when :get
      #  http_client.http_get
      #when :post
      #  http_client.http_post(request.body)
      #when :put
      #  http_client.http_put(request.body)
      #when :delete
      #  http_client.http_delete
      #else
      #  raise "Unsupported request method #{request.http_method}"
      #end
      http_client
    end

    def run &block
      multi.perform &block
    end

    def queue req
      multi.add req
    end
  end
end
Handsoap::Http.drivers[:multicurb] = Handsoap::MultiCurbDriver

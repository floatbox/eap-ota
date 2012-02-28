# encoding: utf-8
require 'curb'
module Sirena
  class MultiCurbDriver

    cattr_accessor :logger do
      Rails.logger
    end

    include CurlHelper
    include KeyValueInit

    attr_accessor :host, :port, :multi, :timeout, :connect_timeout

    def initialize(*)
      super
      @host ||= Conf.sirena.host
      @port ||= Conf.sirena.port
      @multi ||= Curl::Multi.new
      @timeout ||= 160
      @connect_timeout ||= 5
    end

    # raises Curl::Err::*
    def send_request(*args)
      req = make_request(*args)
      req.perform
      # WTF it isn't automatic?
      raise Curl::Err::HTTPError, req.response_code unless (200..299) === req.response_code

      fix_encoding!(req.body_str)
      req.body_str
    ensure
      logger.info "#{self.class.name}: " + debug_easy(req)
    end

    def send_request_async(*args, &block)
      req = make_request(*args)
      req.on_failure do |klass, msg|
        logger.info "#{self.class.name}: " + debug_easy(req)
        logger.error "#{self.class.name}: #{klass}: #{msg}"
      end
      req.on_success do |response|
        logger.info "#{self.class.name}: " + debug_easy(req)
        fix_encoding!(req.body_str)
        block.call req.body_str
      end
      queue req
    end

    def make_request(body, opts={})
      curl = Curl::Easy.new "http://#{host}:#{port}/"
      curl.timeout = @timeout
      curl.connect_timeout = @connect_timeout
      # enables both deflate and gzip responses
      # curl.encoding = ''
      curl.post_body = body
      curl.headers = {
          'X-Encrypt' => (opts[:encrypt] ? 'true' : 'false'),
          'X-Timeout' => ((opts[:timeout] || 150) + 5).to_s,
          'X-Priority' => (opts[:priority] || 0).to_s
        }
      curl
    end

    # for ruby1.9
    def fix_encoding!(str)
      str.force_encoding('utf-8') if str.respond_to?(:force_encoding)
    end

    def queue req
      multi.add req
    end

    def run &block
      multi.perform &block
    end
  end
end

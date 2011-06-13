# encoding: utf-8
require 'typhoeus'
require 'typhoeus/hydra'
module Sirena
  module Driver
    class Typhoeus

      include KeyValueInit
      include TyphoeusHelper

      attr_accessor :host, :port, :hydra

      def initialize(*)
        super
        @host ||= Conf.sirena.host
        @port ||= Conf.sirena.port
        @hydra ||= ::Typhoeus::Hydra.hydra
      end

      def send_request(*args)
        req = make_request(*args)
        hydra.queue req
        run
        response = req.response
        raise_if_error response
        response.body
      end

      def send_request_async(*args, &block)
        req = make_request(*args)
        req.on_complete do |response|
          begin
            raise_if_error response
            # FIXME обработать ошибку
            block.call response
          rescue => e
            Rails.logger.error "Sirena::Service: async: error: #{e.inspect}"
          end
        end
        hydra.queue req
      end

      def make_request(body, opts={})
        req = ::Typhoeus::Request.new "http://#{host}:#{port}/",
          :method => :post,
          :body => body,
          :timeout => 160 * 1000, # in ms
          :headers => {
            'X-Encrypt' => (opts[:encrypt] ? 'true' : 'false'),
            'X-Timeout' => ((opts[:timeout] || 150) + 5).to_s
          }
      end

      def run
        hydra.run
      end
    end
  end
end

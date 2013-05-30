# encoding: utf-8
require 'riemann/client'

module Monitoring
  module RiemannConnection

    class Client
      # смотреть графики на graphite.eviterra.com

      def initialize host
        return unless Conf.riemann.enabled
        @connection = Riemann::Client.new(host: Conf.riemann.host)
      end

      %w|meter histogram gauge occurrence timer|.each do |type|
        define_method :"#{type}", ->(event_hash={}) do
          event_hash[:tags] = [*event_hash[:tags]]
          event_hash[:tags] << type
          send_event event_hash
        end
      end

      private

      def send_event(event_hash={})
        # чтобы не разрывало с Conf.riemann.enabled = no
        return false unless @connection
        event_hash[:service].gsub! /\./, ' '
        event_hash[:tags] << Rails.env
        # отсылаем ивент в риманн, udp захардкодил
        @connection.udp << event_hash
        # ивентов становится все больше, пускай остается только для дебага
        if Rails.env == 'development'
          Rails.logger.info("RIEMANN: event #{ event_hash } sent to #{ Conf.riemann.host }")
        end
        true
      end
    end
  end
end

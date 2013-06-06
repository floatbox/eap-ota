# encoding: utf-8
require 'riemann/client'

module Monitoring
  module RiemannConnection

    class Client
      # смотреть графики на graphite.eviterra.com

      def initialize
        return unless Conf.riemann.enabled
        @connection = Riemann::Client.new(host: Conf.riemann.host)
      end

      # @!method meter
      # @!method histogram
      # @!method gauge
      # @!method occurrence
      # @!method timer
      # @param [Hash] содержимое ивента
      # @option opts [String] :service полное название метрики с точками или пробелами в качестве разделителя
      # @option opts [Integer] :metric (0) количественная метрика ивента
      # @option opts [String] :host (hostname машины) хост с которого отправлен ивент, как правило не нужно указывать явно
      # @option opts [Array] :tags ([]) массив с тегами, используется для распознавания типа ивента в riemann
      # отправляет в riemann ивент с тегом, одноименным методу(тег определяет вид графика в graphite)
      # @example Отправляет в riemann значение, для отрисовки гистограммы
      #   Monitoring.histogram(service: 'this.is.my.metric.', metric: 3.14)
      #   @return [Boolean] возвращает true, если отправлено
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

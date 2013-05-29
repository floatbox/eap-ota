# encoding: utf-8
require 'riemann/client'

module Monitoring

  class RiemannConnection
    # смотреть потом графики на graphite.eviterra.com / yourhost / test / service

    # содержит все используемые окружения
    @@environments = Dir.glob("./config/environments/*.rb").map { |filename| File.basename(filename, ".rb").downcase }

    # добавляет нужное окружение и отправляет event в riemann по протоколу protocol
    #
    # @param event_hash [Hash] хеш со значениями ивента
    # @return [Hash] возвращает отправленный event_hash
    def self.send_event(event_hash, protocol=:udp)
      return unless Conf.riemann.enabled
      @@connection ||= Riemann::Client.new(host: Conf.riemann.host)
      event_hash = fix_env_tag event_hash
      # отсылаем ивент в риманн
      _send_event(event_hash, protocol)
      Rails.logger.info("RIEMANN: event #{ event_hash } sent to #{ Conf.riemann.host }")
      event_hash
    end

    # отсылает ивент в Riemann
    # @!scope class
    # @!visibility private
    # @param event_hash [Hash] хеш со значениями ивента
    # @return [nil]
    def self._send_event(event_hash, protocol)
      @@connection.send(protocol) << event_hash
    end

    # проверяет, не содержит ли event_hash тег с названием окружения
    # @!scope class
    # @!visibility private
    # @param event_hash [Hash] хеш со значениями ивента
    # @return event_hash [Hash] измененный event_hash
    def self.fix_env_tag event_hash
      event_hash[:tags] = [*event_hash[:tags]]
      # если содержит названия окружений - считаем это ошибкой и удаляем их 
      event_hash[:tags] -= @@environments
      # добавляем текущее окружение в теги
      event_hash[:tags] << Rails.env.downcase
      event_hash
    end

    # подписываемся на событие request_performance
    ActiveSupport::Notifications.subscribe /request_performance/ do |name, start, finish, id, payload|
      event = {
        service: payload[:key],
        tags: [],
        metric: (payload[:value].to_f || 1.0 )
      }
      event[:tags] << payload[:graph_type] if payload[:graph_type]
      send_event event
    end

    private_class_method :_send_event, :fix_env_tag
  end

end

# encoding: utf-8
require 'riemann/client'
module RiemannConnection
  # фабрика соединений с риманом.
  # пока без кэширования/пула.
  #
  #   RiemannConnection.default << { service: 'test service', metric: 5.23 }
  #
  # смотреть потом график на graphite.eviterra.com / yourhost / test / service
  #
  # TODO попытаться автоматически тэгать сообщения хотя бы Rails.env-ом
  def self.default
    Riemann::Client.new(host: Conf.riemann.host)
  end
end

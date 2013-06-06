# encoding: utf-8
module Monitoring
  include Monitoring::Subscribers
  
  class << self
    def riemann
      @riemann ||= Monitoring::RiemannConnection::Client.new
    end

    delegate :meter,
             :histogram,
             :gauge,
             :occurrence,
      to: :riemann
  end
end

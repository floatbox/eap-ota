# encoding: utf-8

module Delayed
  class Worker
    alias_method :old_initialize, :initialize

    include Monitoring

    def initialize
      @creation_time = Time.now
      old_initialize
    end
  end
end


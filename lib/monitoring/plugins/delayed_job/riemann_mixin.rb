# encoding: utf-8

module Monitoring::Plugins::DelayedJob
  # вариант 2, сейчас не используется
  # хуже, так как надо инклудить во все джобы
  module RiemannMixin
    def before(job)
      job.instance_eval do
        delay_time = (Time.now - @attributes["created_at"]).to_f
        @attributes['handler'] =~ /\/object:(\w+)/
        klass = $1
        Monitoring.gauge(
          service: "jobs.startup_time.#{klass.downcase}",
          metric: delay_time
        )
        Rails.logger.info "#{klass} started! Waited for #{delay_time}"
      end
    end
  end
end

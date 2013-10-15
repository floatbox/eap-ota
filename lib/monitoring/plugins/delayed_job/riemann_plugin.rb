# encoding: utf-8

module Monitoring::Plugins::DelayedJob
  class RiemannPlugin < Delayed::Plugin
    callbacks do |lifecycle|
      lifecycle.before(:invoke_job) do |job, *args, &block|

        job.instance_eval do
          delay_time = (Time.now - @attributes["created_at"]).to_f
          @attributes['handler'] =~ /\/object:(\w+)/
          klass = $1
          Monitoring.gauge(
            service: "jobs.startup.time.#{klass.downcase}",
            metric: delay_time
          )
          Rails.logger.info "#{klass} started! Waited for #{delay_time}"
        end

        # следующий коллбек в цепочке
        block.call(job, *args) if block.present?
      end
    end
  end
end


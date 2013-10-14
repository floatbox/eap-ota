# encoding: utf-8

module Monitoring::Plugins::DelayedJob
  class RiemannPlugin < Delayed::Plugin
    callbacks do |lifecycle|
      lifecycle.before(:invoke_job) do |job, *args, &block|
        job.instance_eval do
          gauge :"jobs_startup_time_#{self.class.downcase}", (Time.now - @creation_time).to_f
        end
        # следующий коллбек в цепочке
        block.call(job, *args)
      end
    end
  end
end

# encoding: utf-8

module Monitoring::Plugins::DelayedJob
  # вариант 2, на случай если первый не заведется
  # хуже, так как надо инклудить во все джобы
  module RiemannMixin
    def before(job)
      job.instance_eval do
        gauge :"jobs_startup_time_#{self.class.downcase}", (Time.now - @creation_time).to_f
      end
    end
  end
end
